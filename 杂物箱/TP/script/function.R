# 项目：太平反欺诈
# 作者：赵坤望
# 函数集

library(RODBC)

`%+%` <- function(a, b) {
  paste(a, b, sep = "")
}

PreProc <- function(ini.df) {
  
  ini.df[['事故原因代码']] <- as.character(ini.df[['事故原因代码']])
  
  # 删除总金额
  ini.df[['总金额']] <- NULL
  
  # 驾照、吸烟的格式
  ini.df[['是否有驾照']] <- JZ.XY(ini.df[['是否有驾照']])
  ini.df[['是否吸烟']] <- JZ.XY(ini.df[['是否吸烟']])
  
  
  # 删除NA值
  ini.df <- na.omit(ini.df)
  
  
  # 事故性质等于2
  ini.df <- filter(ini.df, 事故性质 == 2)
  # 去重
  ini.df <- distinct(ini.df)
  
  # 年龄离散化
  ini.df[['年龄等级']] <- SegTheAge(ini.df[['年龄']])
  
  # 调整数据
  res.df <- ini.df[c('事故原因代码', '事故结果', '年龄等级', '婚姻状况', '案件类型', 
                     '事故性质', '是否有驾照', '是否吸烟', '性别', '医院等级', 
                     '发票住院金额', '住院天数', '案件ID')]
  
  # 有错误
  # for (i in 2:10)
  #   ini.df <- ini.df[lowerLimit(ini.df[[i]]), ]
  
  res.df
}

SegTheAge <- function(ini.v) {
  # 年龄分割
  # 离散化的方法
  # 内容详见算法文档
  
  table.v <- table(ini.v)
  pos.v <- as.integer(names(table.v))
  size <- length(ini.v)
  
  # 波峰大概所在的位置
  key.point <- round(mean(as.integer(names(table.v[order(table.v, decreasing = TRUE)][1:3]))))
  # 转换成索引
  # 若有重复，取第一个
  key.point <- which(abs(pos.v - key.point) == (abs(pos.v - key.point) %>% min()))[[1]]
  
  left.point <- key.point
  right.point <- key.point
  
  while (sum(table.v[left.point:right.point]) / size <= 0.4) {
    if (left.point >= 2) left.point  <- left.point - 1
    if (right.point <= max(pos.v) - 2) right.point <- right.point + 1
  }
  
  left.point <- table.v[left.point] %>% names() %>% as.integer()
  right.point <- table.v[right.point] %>% names() %>% as.integer()
  
  res.v <- ini.v
  
  res.v[ini.v <= left.point] <- '(' %+% 'Min' %+% ' - ' %+% left.point %+% ']'
  
  res.v[ini.v > left.point & ini.v <= right.point] <- 
    '(' %+% left.point %+% ' - ' %+% right.point %+% ']'
  
  res.v[ini.v > right.point] <- '(' %+% right.point %+% ' - ' %+% 'Max' %+% ']'
  
  res.v
}

lowerLimit <- function(ini.v, percentage = 0.03) {
  # 纯函数
  # 获取一个向量中频数过少的水平
  
  table.v <- table(ini.v)
  
  # 频数下限
  lower.limit <- round(length(ini.v) * percentage)
  
  rm.name <- names(table.v)[table.v < lower.limit]
  
  # 要删除的赋值为FASLE
  ini.v[ini.v %in% rm.name] <- FALSE
  # 要保留的赋值为TRUE
  ini.v[ini.v %in% setdiff(names(table.v), rm.name)] <- TRUE
  
  res.v <- as.logical(ini.v)
  res.v
}

JZ.XY <- function(ini.v) {
  # 纯函数
  # 规范'是否有驾照'和是否吸烟'的格式
  ini.v[ini.v == 'N'] <- '0'
  ini.v[!ini.v %in% c('0', '1')] <- 1
  as.integer(ini.v)
}

#----------------------------------------------------------

Stabilize <- function(ini.df, rate = 0.005, least = 50){
  # 删去不稳定的住院天数
  
  count.v <- table(ini.df[['住院天数']])
  least.n <- max(rate * nrow(ini.df), least)
  
  select.v <- count.v[count.v >= least.n] %>% names() %>% as.integer()
  
  res.df <- filter(ini.df, 住院天数 %in% select.v)
  
  res.df
}

GetInterval <- function(ini.v) {
  # 返回去掉极值后的数据
  
  ini.v <- sort(ini.v)
  ini.l <- length(ini.v)
  
  if (ini.l <= 4) {
    return(ini.v)
    
  } else if (ini.l <= 15) {
    # 长度为15时截断后与长度为16时取70%值相等。
    return(ini.v[-ini.l][-1])
    
  } else {
    # 取费用的中间70%作为区间
    res.v <- ini.v[floor(ini.l * 0.15):ceiling(ini.l * 0.85)]
    return(res.v)
  }
}

GetAtom <- function(ini.df) {
  if (nrow(ini.df) == 0) {
    return(ini.df)
  }
  
  
  # 分组，获取原子类
  by_ini <- group_by(ini.df,
                     住院天数,
                     事故原因代码, 
                     事故结果, 
                     年龄等级, 
                     婚姻状况, 
                     案件类型, 
                     事故性质, 
                     是否有驾照, 
                     是否吸烟, 
                     性别, 
                     医院等级)
  # 获取原子类信息
  # ZFY数据处理过，已去除极值。
  res.df <- summarise(by_ini, 
                      freq = length(发票住院金额), 
                      ZFY.data = paste(发票住院金额, collapse = ','),
                      AJ.ID = paste(案件ID, collapse = ','))
  # 频数下限为3
  # res.df <- res.df[res.df[['freq']] >= 3, ]
  
  # 清空属性
  res.df <- as.data.frame(res.df) %>% as.tbl()
  res.df[['index']] <- 1:nrow(res.df)
  
  return(res.df)
}

MakeCell <- function(ini.v, std.v, length.c = 5){
  
  if(!is.numeric(ini.v) | !is.numeric(std.v))
    stop("输入类型错误")
  
  std.v <- sort(std.v)
  quan.v <- quantile(std.v)
  
  
  kIQR <- quan.v[4] - quan.v[2]
  
  # 化为整数
  kUp   <- min(quan.v[4] + 1.5*kIQR, max(std.v)) %>% ceiling()
  kDown <- max(quan.v[2] - 1.5*kIQR, min(std.v)) %>% floor()
  
  # 计数
  seg.v <- seq(kDown, kUp, length.out = length.c + 1)  # 分割点向量
  
  cell.v <- vector()  # 方格向量
  
  for(i in 1:length.c){
    cell.v[i+1] <- length(ini.v[seg.v[i] <= ini.v & ini.v < seg.v[i+1]])
  }
  
  # 两个极值
  cell.v[1]  <- length(ini.v[ini.v <  seg.v[1]])  
  cell.v[length.c + 2] <- length(ini.v[ini.v >= seg.v[length.c + 1]])
  
  res.v <- ((cell.v / sum(cell.v)) * 100) %>% round()
  return(res.v)
}

GetProfile <- function(ini.df, length.c = 5) {
  
  ini.df <- select(ini.df, index, ZFY.data)
  
  stand.v <- paste(ini.df[['ZFY.data']], collapse = ',') %>% strsplit(split = ',') %>%
    unlist() %>% as.integer() %>% na.omit() %>% as.integer()
  
  res.m <- matrix(0, nrow = nrow(ini.df), ncol = length.c + 3)
  
  colnames(res.m) <- c('index', '下极值', 1:length.c, '上极值')
  
  # 复制，防止错误。
  res.m[, 'index'] <- ini.df[['index']]
  
  
  for(i in 1:nrow(ini.df)){
    
    a.c <- ini.df[i, 'ZFY.data'] %>% as.character() %>% strsplit(split = ',') %>% 
      unlist() %>% as.integer() %>% MakeCell(stand.v)
    for(j in 1:length(a.c)){
      res.m[i, j+1] = a.c[j]
    }
  }
  
  res.m
  
}


GetVar <- function(ini.a, ini.b) {
  
  ini.v <- paste(ini.a, ini.b, sep = ',')
  
  res.v <- vector()
  for (i in 1:length(ini.v)) {
    a.c <- strsplit(ini.v[i], split = ',') %>% unlist() %>% as.integer()
    
    a.c <- (var(a.c) %>% sqrt()) / mean(a.c)
    a.c <- round(a.c, digits = 4)
    res.v <- append(res.v, a.c)
  }
  
  return(res.v)
}

SegByVar <- function(ini.df) {
  
  ini.df  <- select(ini.df, index, ZFY.data) %>% arrange(index)
  dist.df <- outer(ini.df[['ZFY.data']], ini.df[['ZFY.data']], GetVar) %>% as.dist()
  fit.seg <- hclust(dist.df, 'average')
  ini.n <- nrow(ini.df)
  clusters <- cutree(fit.seg, 5)
  clusters
}

SegByMean <- function(ini.df) {
  ini.df  <- select(ini.df, index, ZFY.data) %>% arrange(index)
  ini.df[['ZFY.mean']] <- strsplit(ini.df[['ZFY.data']], split = ',') %>% 
    lapply(as.integer) %>% lapply(mean) %>% unlist()
  
}

CosSimi <- function(x, y){
  # 结果为1-余弦相似度
  # 为配合距离矩阵
  
  r <- vector()
  for (i in 1:length(x)){
    a <- as.double(unlist(strsplit(x[i], split = ",")))
    b <- as.double(unlist(strsplit(y[i], split = ",")))
    
    k1 <- sum(a * b)
    k2 <- sqrt(sum(a^2))
    k3 <- sqrt(sum(b^2))
    r[i] <- 1 - (k1 / ((k2 * k3) + 0.000001))
  }
  r <- round(r, digits = 2)
  return(r)
}

SegByProf <- function(ini.m, length.k = 5) {
  
  prof.v <- vector()
  
  # 以index为顺序
  for(i in 1:nrow(ini.m)) {
    prof.v <- append(prof.v, paste(ini.m[i, ][-1], collapse = ','))
  }
  
  dist.m <- outer(prof.v, prof.v, CosSimi) %>% as.dist()
  
  fit.seg <- hclust(dist.m, "average")
  
  # 此处规则可强化
  clusters <- cutree(fit.seg, k = length.k)
  
  # ini.m <- as.data.frame(ini.m)
  # ini.m['cluster'] <- clusters
  
  
  res.df <- data.frame(index = ini.m[, 'index'], cluster = clusters)
  
  res.df
}

GetCombine <- function(cluster.df, atom.df) {
  res.df <- merge(cluster.df, atom.df, by = 'index') %>% as.tbl()
  
  
  for (i in 1:max(res.df[['cluster']])){
    a.c <- res.df[res.df[['cluster']] == i, 'ZFY.data'] %>%　unlist() %>% paste(collapse = ',')
    
    res.df[res.df[['cluster']] == i, 'cluster.data'] <- a.c
    
    a.c <- strsplit(a.c, split = ',') %>% unlist() %>% as.double()
    
    b.c <- quantile(a.c, prob = c(0.25, 0.75)) %>% paste(collapse = ',')
    
    res.df[res.df[['cluster']] == i, 'cost.range'] <- b.c
}
  
  
  
  res.df <- select(res.df, 
                   cluster,
                   事故原因代码,
                   事故结果,
                   年龄等级,
                   婚姻状况,
                   案件类型,
                   事故性质,
                   是否有驾照,
                   是否吸烟,
                   性别,
                   医院等级,
                   住院天数,
                   AJ.ID, 
                   cost.range)
  
  res.df
}

GetMB <- function(ini.df) {
  
  res.df <- ini.df[c('事故原因代码', '事故结果', '年龄等级', '婚姻状况', 
                     '案件类型', '事故性质', '是否有驾照', '是否吸烟', '性别', 
                     '医院等级')]
  
  cost <- strsplit(ini.df[['cost.range']], split = ',') %>% lapply(as.double)
  
  res.df[['费用下限']] <- lapply(cost, min) %>% unlist() %>% round(digits = 2)
  res.df[['费用上限']] <- lapply(cost, max) %>% unlist() %>% round(digits = 2)
  
  
  
  
  
}















