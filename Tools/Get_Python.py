"""
Read the memory of Pytohn in Memory Base
"""

import pandas as pd
import numpy as np


def main():
    """pass
    """
    # ==============================
    # add python memory
    # ==============================
    try:
        memo = pd.read_csv('MemoBase/MB_Python.csv', encoding='GBK')
    except UnicodeDecodeError:
        memo = pd.read_csv('MemoBase/MB_Python.csv', encoding='GBK')
    memo = memo.fillna('')
    memo = np.array(memo).astype(str)

    try:
        memo_new = pd.read_csv('New_Python.csv')
    except UnicodeDecodeError:
        memo_new = pd.read_csv('New_Python.csv', encoding='GBK')
    _columns = memo_new.columns
    memo_new = memo_new.fillna('')
    memo_new = np.array(memo_new).astype(str)

    # 找出重复项
    repeat_index = np.logical_and(
        np.in1d(memo[:, 1], memo_new[:, 1]),
        np.in1d(memo[:, 0], memo_new[:, 0])
    )
    # 删除
    memo = memo[~repeat_index, :]

    # 合并
    memo_re = np.r_[memo, memo_new]

    # 排序
    memo_re = pd.DataFrame(memo_re)
    memo_re = memo_re.sort_values(by=[0, 1])
    memo_re.columns = _columns

    # 保存
    memo_re.to_csv('MemoBase/MB_Python.csv', header=True, index=False)
    memo_re.to_csv('MB_Python_view.csv', header=True, index=False)

    # 清空python_new
    pd.DataFrame([], columns=_columns).to_csv(
        'New_Python.csv', header=True, index=False)


# ==============================
# generate Python Kindle Book
# ==============================

    with open('MB_Python.txt', 'w') as f_o:

        for i in range(memo.shape[0]):
            f_o.write('## Python Function' + '\n')
            f_o.write(
                '\n' + '\t' + str(memo[i, 0]) + '.' +
                str(memo[i, 1]).replace('.', '') + '\n')

            if memo[i, 2] != '':
                # i = 104, two line
                parameters = memo[i, 2].split('\n')
                for item in parameters:
                    f_o.write('\t' + item + '\n')

            f_o.write('\n' + memo[i, 3] + '\n\n')


if __name__ == '__main__':
    main()
