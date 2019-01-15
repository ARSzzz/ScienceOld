"""
tmp file
"""

import pandas as pd

source = pd.read_csv('others/source.csv', encoding='GBK')


test = source.iloc[-10000:, :]
train = source.iloc[:-10000, :]

test.to_csv('data/test.csv', encoding='utf-8', index=False)
train.to_csv('data/train.csv', encoding='utf-8', index=False)


class TXT:
    """pass
    """
    def __init__(self):
        self.string = ''

    def add(self, string):
        """pass
        """
        self.string = self.string + string + '\n'

    def save(self):
        """pass
        """
        with open('',
                  mode='w') as _f:
            _f.write(self.string)
