#set.seed(223)
source("kfilter_t.R")

library(rcommon)
last <- function(x) x[length(x)]
plot100 <- function(x,...) plot(x/100,...)
lines100 <- function(x,...) lines(x/100,...)

usuk <- c(read.csv("../dat/usuk.dat")[,1]) / 100

plot100(usuk,type='p',cex=.5)
filt <- kfilter_t(usuk,m0=0,C0=1,n0=1,d0=.01,delta=.8)
lines100(sapply(filt$param, function(p) p$f), lty=2)
filt <- kfilter_t(usuk,m0=0,C0=1,n0=1,d0=.01,delta=1)
lines100(sapply(filt$param, function(p) p$f), lty=1)

#delta_grid <- seq(.6,1,len=5)
delta_grid <- seq(0,1,by=.1)

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
#cat(paste("\ndelta.hat: ", delta.hat),"\n")


