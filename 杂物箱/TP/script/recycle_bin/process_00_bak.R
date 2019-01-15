# 项目：太平反欺诈
# 作者：赵坤望
# 获取数据

library(RODBC)
library(dplyr)
source('script/function.R')

conn <- odbcConnect('TPDB', 'tp_etl', 'test')

################
# 事故原因代码 #
################
sql.DM <- "
--返回：事故原因代码、案件总数
select distinct substr(Accident_id,5,5) 事故原因代码,count(distinct AJBH) 案件总数 from WK_SGJBQK 
where substr(Accident_id,5,5) is not null
--WK_GHDJ中，门诊住院区分（MZZY_KB）类型为住院的案件编号
and ajbh in (select CASENO_YL from wk_ghdj where MZZY_KB='2')
--WK_AJXX中，案件结论（AJJL）=2
and ajbh in (select ajbh from wk_ajxx where ajjl=2)
--选取样本量大于100的疾病
group by substr(Accident_id,5,5) having count( distinct AJBH )>=100
"

# 获取数据
DM = sqlQuery(conn, sql.DM, believeNRows = FALSE, stringsAsFactors = FALSE)
save(DM, file = 'data/DM.RData')
DM = DM[['事故原因代码']]



################
# 费用区间     #
################

sql.cost.interval <- "
select a.accident_id 事故原因代码,
A.CXJG 事故结果,
A.SGRQ-substr(B.csrq,0,4) 年龄,
B.HYZK 婚姻状况,
A.AJLB 案件类型,
A.AJJL 事故性质,
B.JZ 是否有驾照,
B.SFXY 是否吸烟,
B.XB 性别,
A.JGDJ 医院等级,
A.szfy 发票住院金额,
A.ZYTS 住院天数,
A.AJBH 案件ID
from

(select distinct substr(a.Accident_id,5,5) Accident_id,
a.SGDX_ID,
c.CXJG,substr(a.SGRQ,0,4) SGRQ,
b.AJLB,
b.AJJL,
e.JGDJ,
e.szfy, 
e.ZYTS, 
a.AJBH  
from WK_SGJBQK a,WK_AJXX b,WK_CXJBQK c,WK_GHDJ d,

(select t1.AJBH,sum(t2.Out_Date-t2.In_Date)+1 zyts,sum(t2.zfy) szfy,max(t2.JGDJ) JGDJ 
from WK_GHDJ t2,WK_SGJBQK t1
where t1.AJBH=t2.CASENO_YL
and t2.MZZY_KB='2' 
group by t1.AJBH /*住院总天数，发票住院金额，住院机构等级*/ ) e

where a.AJBH=b.AJBH and a.AJBH=c.AJBH and b.ajjl=2 and a.AJBH=d.CASENO_YL and a.AJBH=e.AJBH and e.ZYTS>0 ) A

left join WK_TBRXX B on A.SGDX_ID=B.TBRBH
"

# 获取数据
cost.interval <- sqlQuery(conn, sql.cost.interval, believeNRows = FALSE, 
                          stringsAsFactors = FALSE)
cost.interval <- as.tbl(cost.interval)
# 事故原因代码保持一致
cost.interval <- filter(cost.interval, 事故原因代码 %in% DM)
# 去重
cost.interval <- distinct(cost.interval)

# 预处理
# 年龄大于100的，设为100
cost.interval[['年龄']][cost.interval[['年龄']] > 100] == 100
# 删除样本量过小的水平
for(i in 2:10){
  lowerLimit(cost.interval[[i]])
}
for(i in c('是否有驾照', '是否吸烟')){
  cost.interval[[i]] <- JZ.XY(cost.interval[[i]])
}
# 若 ‘发票住院金额’ 为空，则删去改行
cost.interval <- cost.interval[!is.na(cost.interval[['发票住院金额']]), ]

# 以'事故原因代码'分割
cost.interval[['事故原因代码']] <- as.factor(cost.interval[['事故原因代码']])
cost.interval <- split(cost.interval, cost.interval[['事故原因代码']])
save(cost.interval, file = 'data/cost_interval.RData')


################
# 金额数据     #
################
JE.data <- list()
for (i in 1:length(cost.interval)) {
  JE.data[[i]] <- select(cost.interval[[i]], -住院天数)
}
names(JE.data) <- names(cost.interval)
save(JE.data, file = 'data/JE_data.RData')
rm(cost.interval, JE.data)


################
# 项目数据     #
################
sql.XM <- "
select distinct a.accident_id 事故原因代码,a.AJBH 案件ID,b.YYXMDM 项目代码,b.XMJE/a.SZFY 项目金额比例 
from 

(select (case when length(a.Accident_id)>5 then substr(a.Accident_id,5,5) else a.Accident_id end) accident_id,a.AJBH,e1.SZFY  
from  WK_SGJBQK a,WK_GHDJ d,
(select a2.AJBH,sum(a1.zfy) szfy from WK_GHDJ a1,WK_SGJBQK a2 where a1.CASENO_YL=a2.AJBH and a1.MZZY_KB='2' group by a2.AJBH ) e1 
where a.AJBH=d.CASENO_YL and a.AJBH=e1.AJBH and e1.SZFY>0 ) a 

left join

(select a2.AJBH,trim(a3.YYXMDM) YYXMDM,sum(JE) XMJE from WK_GHDJ a1,WK_SGJBQK a2,WK_CFMX a3 where a1.CASENO_YL=a2.AJBH and a1.MZZY_KB='2' 
and a1.GHDJ_CD=a3.GHDJ_CD group by a2.AJBH,trim(a3.YYXMDM) /*项目金额 - 需现场验证*/ ) b

on a.AJBH=b.AJBH 
where a.ajbh in (select CASENO_YL from wk_ghdj where MZZY_KB='2') and a.ajbh in (select ajbh from wk_ajxx where ajjl=2)
"

XM.data <- sqlQuery(conn, sql.XM, believeNRows = FALSE, stringsAsFactors = FALSE)
XM.data <- as.tbl(XM.data)
XM.data <- filter(XM.data, 事故原因代码 %in% DM)
XM.data <- distinct(XM.data)

XM.data[['事故原因代码']] <- as.factor(XM.data[['事故原因代码']])
XM.data <- split(XM.data, XM.data[['事故原因代码']])
save(XM.data, file = 'data/XM_data.RData')
rm(XM.data)



################
# 并发症       #
################

# 列：事故原因代码
# 列：案件ID
# 列：疾病代码1         还得了哪些病
# 列：疾病金额比例      总费用分几次支付，数据重复。

# 一个案件ID下的一个疾病代码，其和为1
# 其数据是重复的
# 应该是票据求和

sql.BFZ = "
select distinct substr(a.Accident_id,5,5) 事故原因代码,
a.AJBH 案件ID,
substr(d.accident_id,5) 疾病代码1,
b.zfy/c.szfy 疾病金额比例
from

WK_SGJBQK a,
WK_GHDJ b,

(select t2.AJBH,sum(t1.zfy) szfy 
from WK_GHDJ t1,WK_SGJBQK t2 
where t1.CASENO_YL=t2.AJBH 
and t1.MZZY_KB='2' 
group by t2.AJBH ) c,

t_claim_sick_cause d

where a.AJBH=b.CASENO_YL 
and a.AJBH=c.AJBH 
and d.hospitalization_id=b.ghdj_cd
and b.MZZY_KB='2' 
and c.szfy>0 
and a.ajbh in (select CASENO_YL from wk_ghdj where MZZY_KB='2') 
and a.ajbh in (select ajbh from wk_ajxx where ajjl=2)
"

BFZ.data <- sqlQuery(conn, sql.BFZ, believeNRows = FALSE, 
                     stringsAsFactors = FALSE)
BFZ.data <- as.tbl(BFZ.data)
BFZ.data <- filter(BFZ.data, 事故原因代码 %in% DM)
BFZ.data <- distinct(BFZ.data)
BFZ.data[['事故原因代码']] <- as.factor(BFZ.data[['事故原因代码']])
BFZ.data <- split(BFZ.data, BFZ.data[['事故原因代码']])
save(BFZ.data, file = 'data/BFZ_data.RData')
rm(BFZ.data)



################
# 险种和责任   #
################

sql.XZZR <- "
select distinct substr(a.Accident_id,5,5) 事故原因代码,
a.AJBH 案件ID,
g.product_id 险种代码,
g.liab_id 责任ID,
g.PFJE/s1.SPF 责任赔付比例
from  

WK_SGJBQK a,
WK_XZ_ZR g,
(select AJBH,sum(PFJE) SPF from WK_XZ_ZR group by AJBH having sum(PFJE)>0 ) s1

where a.AJBH=g.AJBH 
and a.AJBH=s1.AJBH 
and g.PFJE/s1.SPF>0 
and a.ajbh in (select CASENO_YL from wk_ghdj where MZZY_KB='2')  
and a.ajbh in (select ajbh from wk_ajxx where ajjl=2)  
"
XZZR.data <- sqlQuery(conn, sql.XZZR, believeNRows = FALSE,
                      stringsAsFactors = FALSE)
XZZR.data <- as.tbl(XZZR.data)
XZZR.data <- filter(XZZR.data, 事故原因代码 %in% DM)
XZZR.data <- distinct(XZZR.data)

XZZR.data[['事故原因代码']] <- as.factor(XZZR.data[['事故原因代码']])
XZZR.data <- split(XZZR.data, XZZR.data[['事故原因代码']])
save(XZZR.data, file = 'data/XZZR_data.RData')
