set.seed(223)
source("kfilter.R")
library(rcommon)

usuk <- ts(read.csv("../dat/usuk.dat")[,1]) / 100

plot(usuk,type='b',pch=20)

delta_grid_size <- 5
delta_grid <- seq(.6,1,len=delta_grid_size)
lls <- sapply(delta_grid, function(d) {
  filt <- kfilter(usuk,delta=d,m0=0,C0=1,n0=1,d0=.01)
  ll_pred_density(filt,B=10000)
})

llr <- apply(lls, 2, function(k) k-lls[,ncol(lls)])
llr_mean <- apply(llr,2,mean)
llr_ci <- apply(llr,2,quantile,c(.025,.975))

print(llr_mean)

plot(delta_grid,llr_mean,type='b',col='steelblue',
     ylim=range(llr_ci),
     lwd=3,bty='n',fg='grey',
     ylab='density',xlab=expression(delta),
     main='Observed Predicted log Density\n\n',col.main='grey30')
color.btwn(delta_grid, llr_ci[1,],llr_ci[2,],
           from=0,to=delta_grid_size, col.area=rgb(0,0,0,.2))
delta.hat <- delta_grid[which.max(llr_mean)]
abline(v=delta.hat,col='grey',lwd=2)
title(main=bquote(hat(delta) == .(delta.hat)))

print(paste("delta.hat: ", delta.hat))


#filt <- kfilter(usuk,delta=1,m0=0,C0=1,n0=1,d0=.01)
#theta <- kfilter.theta(filt)
#plot(usuk); lines(apply(theta,2,mean))
