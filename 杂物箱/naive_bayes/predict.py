"""
预测
"""

import numpy as np
import pandas as pd


class DisPredict:
    """使用朴素贝叶斯

    """

    def __init__(self):
        """pass
        """
        self.icd_list = None
        self.code_pool = None
        self.info_pool = None
        self.multi_index = None

        self.code_pool = pd.Series(
            np.load('data/code_pool.npy'),
            index=np.load('data/code_pool_index.npy')
        )

        multi_index = np.load('data/info_pool_index.npy')
        self.info_pool = pd.Series(
            np.load('data/info_pool.npy'),
            index=[multi_index[:, 0], multi_index[:, 1]]
        )
        self.info_pool.sort_index(inplace=True)
        self.code_index = pd.Series(multi_index[:, 0])
        self.xm_index = pd.Series(multi_index[:, 1])

        self.icd_list = pd.unique(self.code_index)

    def predict(self, xm_list):
        """pass

        """

        self.info_pool[:][self.xm_index.isin(xm_list).values]

        for icd in self.icd_list:
            print(icd)
            self.info_pool[icd][xm_list]


def main():
    """main 函数

    """
    source = pd.read_csv(
        'others/source.csv',
        index_col=['ID'],
        encoding='GBK',
        keep_default_na=False,)

    id_list = source.index.unique()

    for _id in id_list:
        print(_id)
        xm_list = source.loc[_id, 'XMDM'].tolist()


if __name__ == '__main__':
    main()
