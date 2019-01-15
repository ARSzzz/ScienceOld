"""
pass
"""

import re
from multiprocessing import Pool, cpu_count
import numpy as np
import pandas as pd
from sklearn.naive_bayes import MultinomialNB
from sklearn.externals import joblib


class Model:
    """使用多项式朴素贝叶斯

    """

    def __init__(self, pool):
        """pass

        """
        self.model = None
        self.file_path = None   # 源文件路径
        self.header = None
        self.classes = None     # 疾病的种类
        self.batch_num = None
        self.pool = None
        self.ks_priori = None   # 科室先验矩阵
        self.debug = None
        self.filter_regx = None  # 辅助用药的过滤正则条件

        # 设置
        self.file_path = 'data/train.csv'
        self.ks_info_path = 'data/KS_DIS_INFO.csv'
        self.pool = pool

    @property
    def iter_obj(self):
        """
        原始文件的迭代器
        """
        if self.file_path:
            iter_obj = pd.read_csv(
                self.file_path,
                index_col=['ID'],
                encoding='utf-8',
                keep_default_na=False,
                chunksize=200000
            )
        else:
            iter_obj = None

        return iter_obj

    def get_ks_priori(self):
        """获取疾病与科室的先验信息

        """
        info_df = pd.read_csv(
            self.ks_info_path,
            encoding='utf-8',
            index_col=['CYZDDM', 'KSMC'])

        priori_list = []
        for _class in self.classes:
            sub_df = info_df.loc[[_class]].copy()
            sub_df['prob'] = sub_df['CNT'] / sub_df['CNT'].sum()
            priori_list.append(sub_df[['prob']])

        ks_priori = pd.concat(priori_list)
        ks_priori = ks_priori[['prob']]
        ks_priori.to_csv('data/ks_priori.csv', encoding='utf-8')
        self.ks_priori = ks_priori['prob']

    def param_initializer(self, load=False):
        """将header和classes初始化

        """
        # 辅助用药的正则条件
        filter_regx = pd.read_csv('data/drug_fzyy.csv')
        self.filter_regx = '|'.join(filter_regx['NAME'])

        if not load:

            # 训练新模型时
            header = set()
            classes = set()
            # id_set = set()
            iter_obj = self.iter_obj
            batch_num = 0  # batch的个数

            for batch in iter_obj:
                header = header.union(
                    set(batch['XMDM'].unique())
                )
                classes = classes.union(
                    set(batch['CYZDDM'].unique())
                )
                batch_num += 1

            self.header = np.array(list(header))
            self.classes = np.array(list(classes))

            # 排序
            self.header.sort()
            self.classes.sort()
            self.batch_num = batch_num  # 只用于训练模型
            self.get_ks_priori()  # 获取科室先验信息
        else:
            self.header = np.load('data/header.npy')
            self.classes = np.load('data/classes.npy')
            self.ks_priori = pd.read_csv(
                'data/ks_priori.csv',
                index_col=['CYZDDM', 'KSMC'],
                encoding='utf-8'
            )
            self.ks_priori = self.ks_priori['prob']

    @staticmethod
    def transpose(triple):
        """将一个患者的项目信息拉直，和对应的icd代码一并返回

        """
        batch, header_index, _id = triple

        # 必须要拷贝，否则直接修改原内存
        header_index_cp = header_index.copy()

        used_xmdm = batch.loc[_id, ['XMDM', 'ZJE']].copy()
        if isinstance(used_xmdm, pd.DataFrame):
            used_xmdm = used_xmdm.set_index('XMDM').sum(level='XMDM')
            used_xmdm[used_xmdm['ZJE'] < 0] = 0  # 小于0，则赋值为0

            if used_xmdm['ZJE'].sum() < 1:
                # 所用金额过少，1元
                # 项目全部抵消的，向量全为0
                header_index_cp = header_index_cp.astype(int)
            else:
                used_xmdm = used_xmdm / used_xmdm.sum() * 4

                # 使用ceiling，若有项目全部抵消，ceil后为0
                header_index_cp[used_xmdm.index] = used_xmdm['ZJE']\
                    .map(np.ceil).astype(int)
        else:
            assert isinstance(used_xmdm, pd.Series)
            # 自定义系数
            header_index_cp[used_xmdm['XMDM']] = 1

        # 获取所属的类
        try:
            _class = batch.loc[_id, 'CYZDDM'].iloc[0]
        except AttributeError:
            _class = batch.loc[_id, 'CYZDDM']
            assert isinstance(_class, str)
        
        if np.any(header_index_cp < 0):
            print(_id)

        return header_index_cp.values, _class

    @staticmethod
    def filter_fzyy(batch, regx):
        """删除train中的辅助用药对应的行
        """
        batch = batch.loc[
            batch['XMMC'].map(
                lambda x: False if re.search(regx, x) else True
            ), :
        ]
        return batch

    def gen_train_pair(self, batch, train=True):
        """pass

        """
        # 去掉辅助用药的项目
        # batch = self.filter_fzyy(batch, self.filter_regx)

        id_list = batch.index.unique()

        if id_list.size < 10:
            # id数太少
            return None, None

        # 去掉首位两个患者的记录
        id_list = id_list[id_list != batch.index[0]]
        id_list = id_list[id_list != batch.index[-1]]

        # id_list = batch.index.value_counts()
        # id_list = id_list[id_list > 3]
        # id_list = id_list[1:-1].index

        batch['JE'] = batch['JE'].abs()  # 金额调整为正值
        batch.loc[:, 'ZJE'] = batch['SL'] * batch['JE']
        # 训练时，只选用到的列
        if train:
            batch = batch[['XMDM', 'CYZDDM', 'ZJE']]

        header_index = pd.Series(
            np.zeros(self.header.size),
            index=self.header,
            dtype=int
        )

        iter_triple = zip(
            [batch] * id_list.size,
            [header_index] * id_list.size,
            id_list
        )

        xm_info_list = self.pool.map(self.transpose, iter_triple)
        # xm_info_list = list(map(self.transpose, iter_triple))
        xm_info, class_info = zip(*xm_info_list)

        X = np.stack(xm_info)
        y = class_info

        if train:
            return X, y
        else:
            # 预测时，须返回科室字段,以及ID
            ks = []
            for _id in id_list:
                try:
                    ks_in = batch.loc[_id]['KSMC'].iloc[0]
                except AttributeError:
                    ks_in = batch.loc[_id]['KSMC']
                    assert isinstance(ks_in, str)
                ks.append(ks_in)

            return X, y, id_list, ks

    def train_model(self):
        """pass

        """
        print('开始训练模型！')

        for idx, batch in enumerate(self.iter_obj, 1):

            X, y = self.gen_train_pair(batch)  # pylint: disable=C0103
            if X is None:
                # id数太少
                print('Jump!')
                continue

            _ = self.model.partial_fit(
                X,
                y,
                classes=self.classes)

            print(idx, '/', self.batch_num, '   OK!')

    def new_model(self):
        """重新训练模型

        """

        # 初始化
        # self.model = BernoulliNB()
        self.model = MultinomialNB()
        # self.model = GaussianNB()

        self.param_initializer()
        self.train_model()

        # 保存到本地
        joblib.dump(self.model, "data/BernoulliNB_Model.m")
        np.save('data/header', self.header)
        np.save('data/classes', self.classes)

    def load_model(self):
        """载入已经训练好的模型

        """
        self.param_initializer(load=True)
        self.model = joblib.load('data/BernoulliNB_Model.m')

    def score(self, top=10):
        """获取模型准确率

        """
        test_batch = pd.read_csv(
            'data/test.csv',
            index_col=['ID'],
            encoding='utf-8',
        )

        # 加入疾病过滤！！！
        test_batch = test_batch.loc[
            test_batch['XMDM'].isin(self.header), :]

        test_batch = test_batch.loc[
            test_batch['CYZDDM'].isin(self.classes), :]

        test_batch = test_batch.loc[
            test_batch['KSMC'].isin(self.ks_priori.index.levels[1]), :]

        X, y, id_list, ks = self.gen_train_pair(test_batch, train=False)

        prob_matrix = pd.DataFrame(
            self.model.predict_proba(X),
            columns=self.model.classes_,
            index=ks
        )
        correct = 0
        re_list = []
        for idx, info in enumerate(prob_matrix.iterrows()):
            ks, prob = info
            prob = prob.sort_values(ascending=False)

            # 乘以科室的先验信息
            ks_dis_prob = self.ks_priori.loc[:, ks]
            prob = prob.mul(
                ks_dis_prob,
                fill_value=0).sort_values(ascending=False)

            mark = False
            if y[idx] in prob[:top].index:
                correct += 1
                mark = True

            re_list.append(
                pd.DataFrame(
                    np.array([
                        [id_list[idx]] * top,
                        prob[:top].index.tolist(),
                        [y[idx]] * top,
                        [mark] * top
                    ]).T,
                    columns=['ID', 'predict', 'correct', 'mark']
                )
            )
        correct_rate = correct / len(y)
        re_df = pd.concat(re_list)
        re_df.to_csv('data/result.csv', encoding='GBK', index=False)

        return correct_rate


def test():
    """test
    """
    process_pool = Pool(cpu_count())
    model = Model(process_pool)
    model.new_model()
    print(model.score(1))


if __name__ == '__main__':
    test()
