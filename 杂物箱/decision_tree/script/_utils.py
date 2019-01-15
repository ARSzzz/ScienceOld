"""
utils
"""

import cx_Oracle
import pandas as pd
import numpy as np
import os


def get_input_data():
    """pass"""
    # pylint: disable=E1101
    if os.path.exists('data/source_data.csv'):
        source_data = pd.read_csv('data/source_data.csv')

    else:
        conn = cx_Oracle.Connection(
            'enigma',
            'enigma123',
            '192.168.4.30:1521/orcl',
            encoding='utf-8')

        with open('others/input_data.sql', encoding='utf-8') as f:
            sql_string = f.read()

        source_data = pd.read_sql(sql_string, conn)
        source_data.to_csv('data/source_data.csv', index=False)

    return source_data


# def cal_variation(series):
#     """
#     计算变异系数
#     """
#     type_counts = series.index.value_counts()


class PatientAttr:
    """
    机构类别    discrete variable
    患者类别    discrete variable
    科室名称    discrete Variable
    。。性别    discrete variable
    机构代码    discrete variable
    。总金额    continuous variable

    """
    def __init__(self, source_data):
        self.feature_names = None
        self.col_dict = None
        self.col_dict_inverse = None
        self.data = None
        self.target = None

        self.initialize(source_data)

    def initialize(self, df):
        if not isinstance(df, pd.DataFrame):
            raise ValueError('输入数据必需为DataFrame！')

        self.col_dict = {}
        self.col_dict_inverse = {}
        self.feature_names = ['机构类别', '患者类别', '科室名称', '性别', '机构代码']

        # 机构类别
        types = df['机构类别'].unique()
        types.sort()
        self.col_dict['机构类别'] = dict(zip(range(1, types.size+1), types))
        self.col_dict_inverse['机构类别'] = dict(zip(
            types,
            range(1, types.size+1)
        ))
        df['机构类别'] = df['机构类别'].map(self.col_dict_inverse['机构类别'])

        # 患者类别
        self.col_dict['患者类别'] = {}
        self.col_dict_inverse['患者类别'] = {}
        types = df['患者类别'].unique()
        types.sort()
        self.col_dict['患者类别'] = dict(zip(range(1, types.size+1), types))
        self.col_dict_inverse['患者类别'] = dict(zip(
            types,
            range(1, types.size+1)
        ))
        df['患者类别'] = df['患者类别'].map(self.col_dict_inverse['患者类别'])

        # 科室名称
        self.col_dict['科室名称'] = {}
        self.col_dict_inverse['科室名称'] = {}
        types = df['科室名称'].unique()
        types.sort()
        self.col_dict['科室名称'] = dict(zip(range(1, types.size+1), types))
        self.col_dict_inverse['科室名称'] = dict(zip(
            types,
            range(1, types.size+1)
        ))
        df['科室名称'] = df['科室名称'].map(self.col_dict_inverse['科室名称'])

        # 性别
        self.col_dict['性别'] = {}
        self.col_dict_inverse['性别'] = {}
        types = df['性别'].unique()
        types.sort()
        self.col_dict['性别'] = dict(zip(range(1, types.size+1), types))
        self.col_dict_inverse['性别'] = dict(zip(
            types,
            range(1, types.size+1)
        ))
        df['性别'] = df['性别'].map(self.col_dict_inverse['性别'])

        # 机构代码
        self.col_dict['机构代码'] = {}
        self.col_dict_inverse['机构代码'] = {}
        types = df['机构代码'].unique()
        types.sort()
        self.col_dict['机构代码'] = dict(zip(range(1, types.size+1), types))
        self.col_dict_inverse['机构代码'] = dict(zip(
            types,
            range(1, types.size+1)
        ))
        df['机构代码'] = df['机构代码'].map(self.col_dict_inverse['机构代码'])

        self.target = df['总金额'].values
        self.data = df[self.feature_names].values
