source("kfilter.R")
library(rcommon)

dat <- read.csv("../dat/googletrendsUCSC.csv")

t_axis <- levels(dat[,1])
ucsc <- dat[,2]
N <- length(ucsc)
total.years <- round(N/12)
ind <- c(0,seq(12,N,by=12))
label <- c('2004', sapply(t_axis[ind],function(x)substr(x,1,4)))


filt <- kfilter(ucsc,delta=.8,m0=50,C0=100)

theta <- kfilter.theta(filt,1000)
theta.mean <- apply(theta,2,mean)
ci <- apply(theta,2,quantile,c(.025,.975))

# Plots
plot(0,0, xlim=c(0,N+20), ylim=c(0,100), type='n',bty='n',
     fg='grey',xaxt='n',
     xlab='Year',ylab='Google Volume Index',las=2,
     main='Google Trend – UCSC Websearches',col.main='grey30')

axis(1,fg='grey',at=ind,label=label,las=1)
abline(v=ind,col='grey80',lty=2)
lines(1:N, ucsc, col='grey30',lwd=1)

lines(1:N,theta.mean,lty=2,col='grey30')
color.btwn(1:N,ci[1,],ci[2,],from=1,to=N,col.area=rgb(0,0,0,.2))

# Constant Forecast (of theta):
y_new <- rep(tail(theta.mean,1),12)
sd_new <- matrix(ci[,ncol(ci)],nrow=12,ncol=2,byrow=TRUE)
fut_ind <- (N+1):(N+12)
lines(fut_ind, y_new, col='steelblue', lwd=3)
color.btwn(fut_ind,sd_new[,1],sd_new[,2],from=N+1,to=N+12,
           col.area=rgb(0,0,1,.2))
