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


class PatientInfoClass:
    """
    患者属性：

    字段名          类型              缺失标识
    ID                               不可缺失
    机构类别        categorical       missing
    医疗类别        categorical       missing
    患者年龄        discrete          -1
    患者性别        categorical       missing
    机构等级        categorical       missing
    住院天数        discrete          -1
    总金额          continious        不可缺失
    出院诊断代码    categorical       不可缺失

    """
    def __init__(self, source_data):
        self.feature_names = None
        self.data = None
        self.target = None

        self.initialize(source_data)

    def initialize(self, df):
        if not isinstance(df, pd.DataFrame):
            raise ValueError('输入数据必需为DataFrame！')

        df['总金额'].quantile(0.9)
        
