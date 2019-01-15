# 项目：太平反欺诈
# 作者：赵坤望
# 获取模板

library(dplyr)
source('script/function.R', encoding = 'UTF-8')


# 获取模板数据
load('data/cluster.RData')



###################
# T_MB_XSD        #
###################

# 计数
k = 1
XSD.MB <- data.frame()
T_JB <- data.frame()
AJ.data <- data.frame(DM = vector(),
                      MBBH = vector(), 
                      ID = vector())
for (i in 1:length(cluster.list)) {
  
  a.c.i <- cluster.list[[i]]
  
  for (j in 1:max(a.c.i[['cluster']])) {
    
    a.c.r <- a.c.i[a.c.i[['cluster']] == j, c('事故原因代码', '事故结果', 
                                              '年龄等级', '婚姻状况', '案件类型', 
                                              '事故性质', '是否有驾照', '是否吸烟', 
                                              '性别', '医院等级', '住院天数', 'AJ.ID',
                                              'cost.range')]
    
    cost <- strsplit(a.c.r[['cost.range']], split = ',') %>% lapply(as.double)
    a.c.r[['费用下限']] <- lapply(cost, min) %>% unlist() %>% round(digits = 2)
    a.c.r[['费用上限']] <- lapply(cost, max) %>% unlist() %>% round(digits = 2)   
    a.c.r[['cost.range']] <- NULL
    
    
    a.c.r[['HLZYTSSX']] <- max(a.c.r[['住院天数']])
    a.c.r[['HLZYTSXX']] <- min(a.c.r[['住院天数']])
    
    
    a.c.r[['MBBH']] <- k
    
    AJ.data[k, 'DM'] = unique(a.c.r[['事故原因代码']])
    AJ.data[k, 'MBBH'] = k
    AJ.data[k, 'ID'] = paste(a.c.r[['AJ.ID']], collapse = ',')
    k = k + 1
    
    XSD.MB <- rbind(XSD.MB, select(a.c.r, -AJ.ID))
    T_JB <- rbind(T_JB, a.c.r[1, ])
  }
}
rm(a.c.i, a.c.r, cost)

XSD.MB <- rename(XSD.MB, JB_CD = 事故原因代码, SGJG = 事故结果, 
               SGXZ = 事故性质, NL = 年龄等级, HYZK = 婚姻状况, AJLX = 案件类型, 
               XB = 性别, SFYJZ = 是否有驾照, SFXY = 是否吸烟, YYDJ = 医院等级, 
               HLFYSX = 费用上限, HLFYXX = 费用下限, ZYTS = 住院天数)

save(XSD.MB, file = 'result/T_XSD_MB.RData')
rm(XSD.MB)
##################
# T_JBHLX        #
##################

T_JB <- rename(T_JB, TBBH = MBBH, JB_CD = 事故原因代码, SGJG = 事故结果, 
               SGXZ = 事故性质, NL = 年龄等级, HYZK = 婚姻状况, AJLX = 案件类型, 
               XB = 性别, SFYJZ = 是否有驾照, SFXY = 是否吸烟, YYDJ = 医院等级, 
               HLFYSX = 费用上限, HLFYXX = 费用下限)

T_JB <- select(T_JB, TBBH, JB_CD, SGJG, SGXZ, NL, HYZK, AJLX, XB, SFYJZ, SFXY, 
               YYDJ, HLFYSX, HLFYXX, HLZYTSSX, HLZYTSXX)

T_JB[c('TCQDM', 'JKRQ', 'JKRQ_FROM', 'JKRQ_TO', 'SEQ_NO', 'LOGIN_TIME', 
       'LOGIN_ID', 'MODIFY_TIME', 'MODIFY_ID', 'DELE_FLG')] <- NA

save(T_JB, file = 'result/T_JBHLX.RData')
rm(T_JB, cluster.list)


##################
# T_ZYTSTB       #
##################

# 根据AJ.data 那个疾病哪个模板
# 找出案件ID
# 再找对应cost.interval表中的‘发票住院金额’和‘住院天数’。
load('data/cost_interval.RData')

T_ZYTS <- data.frame()
for(i in 1:length(cost.interval)) {
  
  a.c <- cost.interval[[i]]
  
  # 获取疾病代码
  a.c.DM <- names(cost.interval)[i]
  a.c.i <- filter(AJ.data, DM == a.c.DM)
  
  for(j in a.c.i[['MBBH']]){
    # 循环每一个模板
    a.c.AJ <- strsplit(a.c.i[a.c.i[['MBBH']] == j, 'ID'], split = ',') %>%
      unlist() %>% as.integer()
    a.c.case <- filter(a.c, 案件ID %in% a.c.AJ)
    
    if (nrow(a.c.case) == 1) {
      next()
    }
    
    a.c.case <- a.c.case[['住院天数']]
    a.c.case <- density(a.c.case)
    
    a.c.r <- data.frame(JB_CD = a.c.DM, 
                        ZYTS = a.c.case[['x']], 
                        RS = a.c.case[['y']], 
                        TBBH = j, 
                        POINT_CD = 1:length(a.c.case[['x']]))
    
    T_ZYTS <- rbind(T_ZYTS, a.c.r)
  }
}

T_ZYTS[c('TCQDM', 'DATA_YMD', 'SFYX', 'JKRQ_FROM', 'JKRQ_TO', 'SEQ_NO', 
       'LOGIN_TIME', 'LOGIN_ID', 'MODIFY_TIME', 'MODIFY_ID', 'DELE_FLG')] <- NA
save(T_ZYTS, file = 'result/T_ZYTSTB.RData')
rm(a.c, a.c.i, a.c.r, a.c.AJ, a.c.case, a.c.DM, T_ZYTS)



##################
# T_ZYFYTB       #
##################

T_ZYFY <- data.frame()

for(i in 1:length(cost.interval)) {
  
  a.c <- cost.interval[[i]]
  
  # 获取疾病代码
  a.c.DM <- names(cost.interval)[i]
  a.c.i <- filter(AJ.data, DM == a.c.DM)
  
  for(j in a.c.i[['MBBH']]){
    # 循环每一个模板
    a.c.AJ <- strsplit(a.c.i[a.c.i[['MBBH']] == j, 'ID'], split = ',') %>%
      unlist() %>% as.integer()
    a.c.case <- filter(a.c, 案件ID %in% a.c.AJ)
    
    if (nrow(a.c.case) == 1) {
      next()
    }
    
    a.c.case <- a.c.case[['发票住院金额']]
    a.c.case <- density(a.c.case)
    
    a.c.r <- data.frame(JB_CD = a.c.DM, 
                        ZYFY = a.c.case[['x']], 
                        RS = a.c.case[['y']], 
                        TBBH = j, 
                        POINT_CD = 1:length(a.c.case[['x']]))
    
    T_ZYFY <- rbind(T_ZYFY, a.c.r)
  }
}

T_ZYFY[c('TCQDM', 'DATA_YMD', 'SFYX', 'JKRQ_FROM', 'JKRQ_TO', 'SEQ_NO', 
         'LOGIN_TIME', 'LOGIN_ID', 'MODIFY_TIME', 'MODIFY_ID', 'DELE_FLG')] <- NA
save(T_ZYFY, file = 'result/T_ZYFYTB.RData')
rm(a.c, a.c.i, a.c.r, a.c.AJ, a.c.case, a.c.DM, T_ZYFY, cost.interval)





###################
# T_BFZ_MB        #
###################
# 读取数据

load('data/BFZ_data.RData')

BFZ.MB <- data.frame()
# 循环每一个疾病
for (i in 1:length(BFZ.data)){
  
  # 并发症数据
  a.c <- BFZ.data[[i]]
  a.c[['疾病金额比例']] <- NULL
  
  # 并发症数据非空
  a.c <- a.c[!is.na(a.c[['疾病代码1']]), ]
  a.c <- a.c[nchar(a.c[['疾病代码1']]) > 0, ]
  a.c <- unique(a.c)
  
  
  a.c.DM <- names(BFZ.data)[i]
  
  a.c.i <- AJ.data[AJ.data[['DM']] == a.c.DM, ]
  
  # 循环每一个模板
  for (j in a.c.i[['MBBH']]) {
    a.c.AJ <- strsplit(a.c.i[a.c.i[['MBBH']] == j, 'ID'], split = ',') %>%
      unlist() %>% as.integer()
    a.c.case <- filter(a.c, 案件ID %in% a.c.AJ)
    
    a.c.r <- group_by(a.c.case, 疾病代码1) %>% summarise(JBRS = length(案件ID))
    
    a.c.r <- rename(a.c.r, JBDM = 疾病代码1)
    a.c.r[['SGYYDM']] <- a.c.DM
    a.c.r[['ZRS']] <- length(unique(a.c.case[['案件ID']]))
    
    a.c.r[['PL']] <- a.c.r[['JBRS']] / a.c.r[['ZRS']]
    a.c.r[['MBBH']] <- j
    
    BFZ.MB <- rbind(BFZ.MB, a.c.r)
  }
}

BFZ.MB <- select(BFZ.MB, SGYYDM, JBDM, ZRS, JBRS, PL, MBBH)
save(BFZ.MB, file = 'result/T_BFZ_MB.RData')
rm(a.c, a.c.case, a.c.i, a.c.r, a.c.AJ, a.c.DM, BFZ.MB, BFZ.data)




###################
# T_XM_MB        #
###################

load('data/XM_data.RData')
XM.MB <- data.frame()


for (i in 1:length(XM.data)){
  
  # 并发症数据
  a.c <- XM.data[[i]]
  a.c[['项目金额比例']] <- NULL
  
  # 项目数据非空
  a.c <- a.c[!is.na(a.c[['项目代码']]), ]
  a.c <- a.c[nchar(a.c[['项目代码']]) > 0, ]
  a.c <- unique(a.c)
  
  # 删除NOT_MATCH项
  a.c <- a.c[setdiff(1:nrow(a.c), grep('(?i)NOT_MATCH', a.c[['项目代码']])), ]
  
  
  a.c.DM <- names(XM.data)[i]
  a.c.i <- AJ.data[AJ.data[['DM']] == a.c.DM, ]
  
  # 循环每一个模板
  for (j in a.c.i[['MBBH']]) {
    a.c.AJ <- strsplit(a.c.i[a.c.i[['MBBH']] == j, 'ID'], split = ',') %>%
      unlist() %>% as.integer()
    a.c.case <- filter(a.c, 案件ID %in% a.c.AJ)
    
    a.c.r <- group_by(a.c.case, 项目代码) %>% summarise(XMRS = length(案件ID))
    
    a.c.r <- rename(a.c.r, XMDM = 项目代码)
    a.c.r[['SGYYDM']] <- a.c.DM
    a.c.r[['ZRS']] <- length(unique(a.c.case[['案件ID']]))
    
    a.c.r[['PL']] <- a.c.r[['XMRS']] / a.c.r[['ZRS']]
    a.c.r[['MBBH']] <- j
    
    XM.MB <- rbind(XM.MB, a.c.r)
  }
  
  print(i)
}

XM.MB <- select(XM.MB, SGYYDM, XMDM, ZRS, XMRS, PL, MBBH)
save(XM.MB, file = 'result/T_XM_MB.RData')
rm(a.c, a.c.case, a.c.i, a.c.r, a.c.AJ, a.c.DM, XM.MB, XM.data)





###################
# T_XZZR_MB    #
###################

load('data/xzzr_data.RData')
XZZR.MB <- data.frame()


for (i in 1:length(XZZR.data)){
  
  # 并发症数据
  a.c <- XZZR.data[[i]]
  a.c[['责任赔付比例']] <- NULL
  
  # 责任数据非空
  a.c <- a.c[!is.na(a.c[['险种代码']]), ]
  a.c <- a.c[nchar(a.c[['险种代码']]) > 0, ]
  a.c <- unique(a.c)
  
  a.c.DM <- names(XZZR.data)[i]
  a.c.i <- AJ.data[AJ.data[['DM']] == a.c.DM, ]
  
  # 循环每一个模板
  for (j in a.c.i[['MBBH']]) {
    a.c.AJ <- strsplit(a.c.i[a.c.i[['MBBH']] == j, 'ID'], split = ',') %>%
      unlist() %>% as.integer()
    a.c.case <- filter(a.c, 案件ID %in% a.c.AJ)
    
    a.c.r <- group_by(a.c.case, 险种代码, 责任ID) %>% 
      summarise(XZZRRS = length(案件ID))
    
    a.c.r <- rename(a.c.r, XZDM = 险种代码, ZRID = 责任ID) %>% as.data.frame() %>%
      as.tbl()
    a.c.r[['SGYYDM']] <- a.c.DM
    a.c.r[['ZRS']] <- length(unique(a.c.case[['案件ID']]))
    
    a.c.r[['PL']] <- a.c.r[['XZZRRS']] / a.c.r[['ZRS']]
    a.c.r[['MBBH']] <- j
    
    XZZR.MB <- rbind(XZZR.MB, a.c.r)
  }
  
  print(i)
}


XZZR.MB <- select(XZZR.MB, SGYYDM, XZDM, ZRID, ZRS, XZZRRS, PL, MBBH)
save(XZZR.MB, file = 'result/T_XZZR_MB.RData')

rm(list = ls())
