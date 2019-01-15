# 项目：太平反欺诈
# 作者：赵坤望
# 测试用

source('script/function.R', encoding = 'UTF-8')
library(dplyr)


test.name <-  list.files('source')


####################
# 费用区间         #
####################
# 测试
# 人造数据
cost.interval <- read.csv('source/' %+% test.name[1], stringsAsFactors = FALSE) %>% as.tbl()
# 读入金额
JE.data <- read.csv('source/' %+% test.name[3], stringsAsFactors = FALSE) %>% as.tbl()
cost.interval[['总金额']] <- cost.interval[['发票住院金额']] <- JE.data[['发票住院金额']]

# 伪造住院天数
cost.interval[['住院天数']] <- (nrow(cost.interval) %>% rnorm() * 10) %>% abs() %>% ceiling()

# 伪造医院等级
cost.interval[sample(nrow(cost.interval), 200), '医院等级'] <- 2
cost.interval[cost.interval[['医院等级']] =='未', '医院等级'] <- 3
# 模拟list数据结构
x <- cost.interval
cost.interval <- list()
cost.interval[[1]] <- x
cost.interval[[2]] <- x
rm(x)


# 命名为事故原因代码
cost.interval <- lapply(cost.interval, distinct)
names(cost.interval) <- c('J03', 'J03')
# 预处理
cost.interval <- lapply(cost.interval, PreProc)
# 保存
save(cost.interval, file = 'data/cost_interval.RData')



####################
# 金额数据         #
####################
JE.data <- list()
for (i in 1:length(cost.interval))
  JE.data[[i]] <- select(cost.interval[[i]], -住院天数)

names(JE.data) <- names(cost.interval)
save(JE.data, file = 'data/JE_data.RData')
rm(cost.interval, JE.data)



####################
# 项目数据         #
####################
XM.data <- read.csv('source/' %+% test.name[5], stringsAsFactors = F) %>% as.tbl()
# 去重
XM.data <- distinct(XM.data)

# 检验是否为1
# by_ID <- group_by(XM.data, 案件ID)
# summarise(by_ID, sbl = sum(项目金额比例))$tbl


# 模拟list数据结构
x <- XM.data
XM.data <- list()
XM.data[[1]] <- x
XM.data[[2]] <- x
rm(x)
save(XM.data, file = 'data/XM.RData')
rm(XM.data)



####################
# 并发症数据       #
####################
BFZ.data <- read.csv('source/' %+% test.name[2], stringsAsFactors = F)　%>% as.tbl()
# 去重
BFZ.data <- distinct(BFZ.data)

# 模拟list数据结构
x <- BFZ.data
BFZ.data <- list()
BFZ.data[[1]] <- x
BFZ.data[[2]] <- x
rm(x)
save(BFZ.data, file = 'data/BFZ.RData')
rm(BFZ.data)

####################
# 险种责任         #
####################
XZZR.data <- read.csv('source/' %+% test.name[4], stringsAsFactors = F)　%>% as.tbl()
# 去重
XZZR.data <- distinct(XZZR.data)

# 模拟list数据结构
x <- XZZR.data
XZZR.data <- list()
XZZR.data[[1]] <- x
XZZR.data[[2]] <- x
rm(x)
save(XZZR.data, file = 'data/XZZR.RData')
rm(XZZR.data)









