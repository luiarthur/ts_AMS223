#set.seed(223)
source("kfilter.R")
library(rcommon)

usuk <- c(1.35, 1.00, -1.96, -2.17, -1.78, -4.21,
          -3.30, -1.43, -1.35, -0.34, -1.38, 0.30,
          -0.10, -4.13, -5.12, -2.13, -1.17, -1.24,
          1.01, -3.02, -5.40, -0.12, 2.47, 2.06,
          -0.18, 0.29, 0.23, 0.00, 0.06, 0.17,
          0.98, 0.17, 1.59, 2.62, 1.96, 4.28,
          0.26, -1.66, -3.03, -1.80, 1.04, 3.06,
          2.50, 0.87, 2.42, -2.37, 1.22, 1.05,
          -0.05, 1.68, 1.70, -0.73, 2.59, 6.77,
          -0.98, -1.71, -2.53, -0.61, 3.14, 2.96,
          1.01, -3.69, 0.45, 3.89, 1.38, 1.57,
          -0.08, 1.30, 0.62, -0.87, -2.11, 2.48,
          -4.73, -2.70, -2.45, -4.17, -5.76, -5.09,
          -2.92, -0.22, 1.42, 3.26, 0.05, -0.95,
          -2.14, -2.19, -1.96, 2.18, -2.97, -1.89,
          0.12, -0.76, -0.94, -3.90, -0.86, -2.88,
          -2.58, -2.78, 3.30, 2.06, -1.54, -1.30,
          -1.78, -0.13, -0.20, -1.35, -2.82, -1.97,
          2.25, 1.17, -2.29, -2.49, -0.87, -4.15,
          -0.53)

plot(usuk,type='l')

delta_grid_size <- 5
delta_grid <- seq(.6,1,len=delta_grid_size)
lls <- sapply(delta_grid, function(d) {
  filt <- kfilter(usuk,delta=d,m0=0,C0=1,n0=1,d0=.01)
  ll_pred_density(filt,B=10000)
})

llr <- lls-lls[,ncol(lls)]
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
