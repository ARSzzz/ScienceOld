import json
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
# from script.utils import PatientInfoClass


def data_binning(x):
    """
    输入变量x为 pd.Series, 类型为数值型变量
    根据均值 μ 及方差 σ 将分为3箱：
        [-inf, μ-σ]
        [μ-σ,  μ+σ]
        [μ+σ,  inf]
    """
    if not isinstance(x, pd.Series):
        raise ValueError('输入数据必需为 pd.Series！')
    mean, std = x.describe()[['mean', 'std']]
    bins = [mean-std, mean+std]


bins = np.linspace(x.min(), 100000, 20)
pd.cut(x, bins).value_counts().plot(kind='bar')
plt.show()

patient_info = pd.read_csv('data/patient_info.csv')
# with open('data/patient_info_overview.json', encoding='utf-8') as f:
#     patient_info_overview = json.load(f)
