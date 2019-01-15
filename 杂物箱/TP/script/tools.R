for (i in 1:nrow(test)) {
  x.p = as.integer(strsplit(test[i, 'ZYTS.data'][[1]], split = ',')[[1]])
  y.p = as.integer(strsplit(test[i, 'ZFY.data'][[1]], split = ',')[[1]])
  plot(x.p, y.p)
  
}