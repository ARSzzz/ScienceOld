"""
脚本功能;数据预处理
脚本输入：
    Oracle数据库

脚本输出：
    data/qualified_cyzddm.csv
    data/patient_info.csv
    data/patient_info_overview.json

"""

import cx_Oracle
import pandas as pd
import numpy as np
import json


# ==============================
# 重要参数
#
# 出院诊断代码患者计数下限
# ==============================
CYZDDM_MIN_COUNT = 200


# ==============================
# 连接数据库
# ==============================
conn = cx_Oracle.Connection(
    'enigma',
    'enigma123',
    '192.168.4.30:1521/orcl',
    encoding='utf-8'
)


# ==============================
# 获取合格的出院诊断代码
#   1、人数符合计数下限
#   2、删除为None的代码
# ==============================
sql = "\
  select cyzddm 出院诊断代码, count(*) 计数\
    from wuxi.ck10_ghdj\
    where jgmc = '无锡市人民医院'\
    and jzlx = 2\
   group by cyzddm\
   order by 计数 desc\
"

qualified_cyzddm = pd.read_sql(sql, conn)

# 计数满足下限
qualified_cyzddm = qualified_cyzddm.loc[
    qualified_cyzddm['计数'] > CYZDDM_MIN_COUNT, :]

# 出院诊断代码必需存在
qualified_cyzddm = qualified_cyzddm.dropna()

# 保存
qualified_cyzddm.to_csv(
    'data/qualified_cyzddm.csv',
    index=False,
    encoding='utf-8'
)


# ==============================
# 获取患者属性
#
# 字段名          类型              缺失标识
# ID                               不可缺失
# 机构类别        categorical       missing
# 医疗类别        categorical       missing
# 患者年龄        discrete          -1
# 患者性别        categorical       missing
# 机构等级        categorical       missing
# 住院天数        discrete          -1
# 总金额          continious        不可缺失
# 出院诊断代码    categorical       不可缺失
# ==============================
sql = "\
  select ID,\
         jglb   机构类别,\
         yllb   医疗类别,\
         jzlx   就诊类型,\
         hznl   患者年龄,\
         hzxb   患者性别,\
         jgdj   机构等级,\
         zyts   住院天数,\
         zje    总金额,\
         cyzddm 出院诊断代码\
    from wuxi.ck10_ghdj\
   where jgmc = '无锡市人民医院'\
     and jzlx = 2\
     and zje is not null\
     and cyzddm is not null\
"

# 从数据库获取数据
patient_info = pd.read_sql(
    sql,
    conn
)

# 删除不满足人数计数的数据
patient_info = patient_info.loc[
    patient_info['出院诊断代码'].isin(qualified_cyzddm['出院诊断代码']),
    :
]

categorical = ['机构类别', '医疗类别', '患者性别', '机构等级']
patient_info.loc[:, categorical] = patient_info[categorical].fillna('missing')

discrete = ['患者年龄', '住院天数']
patient_info.loc[:, discrete] = patient_info[discrete].fillna(-1)

# 保存
patient_info.to_csv('data/patient_info.csv', index=False, encoding='utf-8')


# ==============================
# 信息概况
#
# categorival 变量为每个种类的计数
# discrete, continuous 变量 为数值分布的统计
# ==============================
info_overview = {}
for _col in categorical:
    print(_col)
    info_overview[_col] = patient_info[_col].value_counts().to_dict()

for _col in discrete:
    print(_col)
    # 精确到小数后4位
    info_overview[_col] = patient_info[_col].describe().round(4).to_dict()

# 保存
with open('data/patient_info_overview.json', 'w', encoding='utf-8') as f:
    json.dump(info_overview, f, ensure_ascii=False, indent=4)
