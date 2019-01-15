# 项目：太平反欺诈
# 作者：赵坤望
# 费用区间分组

#! 测试

library(dplyr)
source('script/function.R', encoding = 'utf-8')

# 载入数据
load('data/cost_interval.RData')

# 获取原子类
Atom.list <- lapply(cost.interval, GetAtom)

# 获取轮廓数据
Profile.list <- lapply(Atom.list, GetProfile)

# 获取分类结果
result.list <- list()
for (i in 1:length(Profile.list)) {
  result.list[[i]] <- SegByProf(Profile.list[[i]])
  print(i %+% ' OK')
}
names(result.list) <- names(Atom.list)

# 合并结果
cluster.list <- list()
for (i in 1:length(Atom.list)) {
  cluster.list[[i]] <- GetCombine(result.list[[i]], Atom.list[[i]])
}
names(cluster.list) <- names(result.list)

save(cluster.list, file = 'data/cluster.RData')

