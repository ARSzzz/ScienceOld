"""
提取信息
"""

import pandas as pd
from utils import InfoExtractor


def main():
    """pass

    """

    source = pd.read_csv(
        'others/source.csv',
        index_col=['CYZDDM', 'XMDM'],
        encoding='GBK',
        keep_default_na=False,
        chunksize=10000)
    info_extractor = InfoExtractor()
    info_extractor.info_extract(source)
    info_extractor.saver()


if __name__ == '__main__':
    main()
