
################
# 金额数据     #
################

sql.JE = "
select Accident_id 事故原因代码,case when CXJG is null then 'X'else CXJG end 案件结果,case when age is null then 999 else age end 年龄,
case when HYZK is null then 'X'else HYZK end 婚姻状况,case when AJLB is null then 'X'else AJLB end 案件类型,
case when AJJL is null then 'X'else AJJL end 案件性质,case when JZ is null then 'X'else JZ end 是否有驾照,
case when SFXY is null then 'X'else SFXY end 是否吸烟,case when XB is null then 'X'else XB end 性别,
case when JGDJ is null then 'X'else JGDJ end 机构等级,SZFY 发票住院金额,AJBH 案件ID
from 


(select a.accident_id,
a.CXJG,
SGRQ-substr(e.csrq,0,4) age,
e.HYZK,
a.AJLB,
a.AJJL, 
e.JZ, 
e.SFXY,
e.XB,
a.JGDJ,
a.szfy,
a.AJBH 
from 

(select distinct (case when length(a.Accident_id)>5 then substr(a.Accident_id,5,5) else a.Accident_id end) accident_id,
a.SGDX_ID,
c.CXJG,
substr(a.SGRQ,0,4) SGRQ,
b.AJLB,
b.AJJL,
e1.JGDJ,
e1.szfy,
a.AJBH  
from 

WK_SGJBQK a,WK_AJXX b,WK_CXJBQK c,WK_GHDJ d,
(select a2.AJBH,sum(a1.zfy) szfy,max(a1.JGDJ) JGDJ from WK_GHDJ a1,WK_SGJBQK a2 
where a1.CASENO_YL=a2.AJBH and a1.MZZY_KB='2' group by a2.AJBH /*住院总天数，发票住院金额，住院机构等级*/ ) e1

where a.AJBH=b.AJBH and a.AJBH=c.AJBH and a.AJBH=d.CASENO_YL and a.AJBH=e1.AJBH and b.ajjl=2 ) a

left join WK_TBRXX e on a.SGDX_ID=e.TBRBH ) 
where ajbh in (select ajbh from wk_ajxx where ajjl=2)
"

JE.data <- sqlQuery(conn, sql.JE, believeNRows = FALSE, stringsAsFactors = FALSE)
JE.data <- as.tbl(JE.data)
# 事故原因代码保持一致
JE.data <- filter(JE.data, 事故原因代码 %in% DM)
# 去重
JE.data <- distinct(JE.data)

# 预处理
# 年龄大于100的，设为100
JE.data[['年龄']][JE.data[['年龄']] > 100] == 100
# 删除样本量过小的水平
for(i in 2:10){
  lowerLimit(JE.data[[i]])
}
for(i in c('是否有驾照', '是否吸烟')){
  JE.data[[i]] <- JZ.XY(JE.data[[i]])
}




JE.data[['事故原因代码']] <- as.factor(JE.data[['事故原因代码']])
JE.data <- split(JE.data, JE.data[['事故原因代码']])



# 预处理
# 若 ‘发票住院金额’ 为空，则删去改行
# cost.interval <- cost.interval[!is.na(cost.interval[['发票住院金额']]), ]
# 年龄大于100的，设为100
# cost.interval[['年龄']][cost.interval[['年龄']] > 100] == 100

# # 删除样本量过小的水平
# for(i in 2:10){
#   lowerLimit(cost.interval[[i]])
# }

# for(i in c('是否有驾照', '是否吸烟')){
#   cost.interval[[i]] <- JZ.XY(cost.interval[[i]])
# }
