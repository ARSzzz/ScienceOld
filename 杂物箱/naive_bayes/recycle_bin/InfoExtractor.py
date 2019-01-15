class InfoExtractor:
    """pass

    """

    def __init__(self):
        """pass
        """
        self.code_pool = None
        self.id_count = None
        self.info_pool = None
        self.multi_index = None

        # 初始化
        self.id_set = set()

    def info_accumulator(self, batch):
        """输入一个数据包batch，将其累加入数据池。

        """
        # 初始化 code_pool
        id_info = batch.reset_index()
        id_info = id_info[['CYZDDM', 'ID']].drop_duplicates()

        if self.code_pool is not None:
            self.code_pool = self.code_pool.add(
                id_info['CYZDDM'].value_counts(),
                fill_value=0
            )
        else:  # 为空
            self.code_pool = id_info['CYZDDM'].value_counts()

        # 将ID数更新
        self.id_count = self.code_pool.sum()

        pair_counts = batch.index.value_counts()

        if self.info_pool is not None:
            self.info_pool = self.info_pool.add(
                pair_counts, fill_value=0)
        else:
            self.info_pool = pair_counts

    def info_extract(self, iter_obj):
        """pass

        """
        for df_obj in iter_obj:
            self.info_accumulator(df_obj)

        multi_index = np.zeros([self.info_pool.size, 2], dtype='O')
        for idx, info in enumerate(self.info_pool.index):
            multi_index[idx, :] = info

        self.info_pool.index = [
            multi_index[:, 0],
            multi_index[:, 1]]
        self.info_pool.sort_index(inplace=True)
        self.multi_index = multi_index

        # 计算百分比
        for code in self.code_pool.index:
            self.info_pool[code] = self.info_pool[code] / self.code_pool[code]
        assert self.info_pool.max() <= 1

        self.code_pool = self.code_pool / self.code_pool.sum()
        assert round(self.code_pool.sum(), ndigits=5) == 1

    def saver(self):
        """pass

        """

        np.save(
            'data/info_pool.npy',
            self.info_pool.values
        )

        np.save(
            'data/info_pool_index.npy',
            self.multi_index
        )

        np.save(
            'data/code_pool.npy',
            self.code_pool.values
        )

        np.save(
            'data/code_pool_index.npy',
            self.code_pool.index.values
        )
