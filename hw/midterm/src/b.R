#set.seed(223)
source("kfilter.R")
library(rcommon)

dat <- read.csv("../dat/googletrendsUCSC.csv")

t_axis <- levels(dat[,1])
ucsc <- dat[,2]
N <- length(ucsc)
total.years <- round(N/12)
ind <- c(0,seq(12,N,by=12))
label <- c('2004', sapply(t_axis[ind],function(x)substr(x,1,4)))

# OBSERVED PREDICTIVE LOG DENSITY
delta_grid_size <- 50
delta_grid <- seq(.5,.99,len=delta_grid_size)
lls <- sapply(delta_grid, function(d) {
  filt <- kfilter(ucsc,delta=d,m0=50,C0=100,n0=4,d0=100)
  ll_pred_density(filt,B=1000)
})

llr <- apply(lls, 2, function(k) k-lls[,ncol(lls)])
llr_mean <- apply(llr,2,mean)
#llr_ci <- apply(llr,2,quantile,c(.025,.975))

plot(delta_grid,llr_mean,type='b',col='steelblue',
     #ylim=range(llr_ci),
     lwd=3,bty='n',fg='grey',ylab='density',xlab=expression(delta),
     main='Observed Predicted log Density\n\n',col.main='grey30')
#color.btwn(delta_grid, llr_ci[1,],llr_ci[2,],from=0,to=delta_grid_size, col.area=rgb(0,0,0,.2))
delta.hat <- delta_grid[which.max(llr_mean)]
abline(v=delta.hat,col='grey',lwd=2)
title(main=bquote(hat(delta) == .(delta.hat)))


# Analysis
filt <- kfilter(ucsc,delta=delta.hat,m0=50,C0=100) # delta.hat=.87?

theta <- kfilter.theta(filt,1000)
theta.mean <- apply(theta,2,mean)
ci <- apply(theta,2,quantile,c(.025,.975))


# Plots
plot(0,0, xlim=c(0,N+12), ylim=c(0,100), type='n',bty='n',
     fg='grey',xaxt='n',
     xlab='Year',ylab='Google Volume Index',las=2,
     main='Google Trend – UCSC Websearches',col.main='grey30')

axis(1,fg='grey',at=c(ind,tail(ind,1)+12),
     label=c(label,tail(strtoi(label),1)+1),las=1)
abline(v=c(ind,tail(ind,1)+12),col='grey80',lty=2)
lines(1:N, ucsc, col='grey30',lwd=1)

lines(1:N,theta.mean,lty=2,col='grey30')
color.btwn(1:N,ci[1,],ci[2,],from=1,to=N,col.area=rgb(0,0,0,.2))

# Constant Forecast (of theta):
y_new <- rep(tail(theta.mean,1),12)
sd_new <- matrix(ci[,ncol(ci)],nrow=12,ncol=2,byrow=TRUE)
fut_ind <- (N+1):(N+12)
lines(fut_ind, y_new, col='steelblue', lwd=3,type='o')
color.btwn(fut_ind,sd_new[,1],sd_new[,2],from=N+1,to=N+12,
           col.area=rgb(0,0,1,.2))


