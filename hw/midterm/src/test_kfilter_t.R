#set.seed(223)
source("kfilter_t.R")

library(rcommon)
last <- function(x) x[length(x)]

usuk <- c(read.csv("../dat/usuk.dat")[,1]) / 100

plot(usuk,type='o',pch=20)
filt <- kfilter_t(usuk,m0=0,C0=1,n0=1,d0=.01,delta=.8)
lines(sapply(filt$param, function(p) p$f), lty=2)
filt <- kfilter_t(usuk,m0=0,C0=1,n0=1,d0=.01,delta=1)
lines(sapply(filt$param, function(p) p$f), lty=1)

delta_grid_size <- 5
delta_grid <- seq(.6,1,len=delta_grid_size)

lls <- sapply(delta_grid, function(d) {
  filt <- kfilter_t(usuk,m0=0,C0=1,n0=1,d0=.01,delta=d)
  ll_pred_density_t(filt)
})

llr <- lls - last(lls)

plot(delta_grid,llr,type='b',col='steelblue',
     lwd=3,bty='n',fg='grey',
     ylab='density',xlab=expression(delta),
     main='Observed Predicted log Density\n\n',col.main='grey30')
delta.hat <- delta_grid[which.max(llr)]
abline(v=delta.hat,col='grey',lwd=2)
title(main=bquote(hat(delta) == .(delta.hat)))

cat("LLR:\n")
names(llr) <- delta_grid
print(llr)
cat(paste("\ndelta.hat: ", delta.hat),"\n")


