set.seed(223)
source("kfilter_t.R")
library(rcommon)

dat <- read.csv("../dat/googletrendsUCSC.csv")

t_axis <- levels(dat[,1])
ucsc <- dat[,2]
N <- length(ucsc)
total.years <- round(N/12)
ind <- c(0,seq(12,N,by=12))
label <- c('2004', sapply(t_axis[ind],function(x)substr(x,1,4)))

# OBSERVED PREDICTIVE LOG DENSITY
delta_grid_size <- 1000
delta_grid <- seq(.6,1,len=delta_grid_size)
lls <- sapply(delta_grid, function(d) {
  filt <- kfilter_t(ucsc,delta=d,m0=50,C0=10,n0=4,d0=20)
  ll_pred_density_t(filt)
})

llr <- lls - last(lls)

pdf("../tex/img/delta.pdf")
plot(delta_grid,llr,type='b',col='steelblue',
     lwd=3,bty='n',fg='grey',ylab='log-density',xlab=expression(delta),
     main='Observed Predicted log Density\n\n',col.main='grey30')
delta.hat <- delta_grid[which.max(llr)]
abline(v=delta.hat,col='grey',lwd=2)
title(main=bquote(hat(delta) == .(delta.hat)))
dev.off()


# Analysis
filt <- kfilter_t(ucsc,delta=delta.hat,m0=50,C0=100) # delta.hat=.87?

theta.mean <- sapply(filt$param, function(p) p$m)
theta.ci <- sapply(filt$param, function(p) 
                   p$m + sqrt(p$C) * qt(c(.025,.975),df=p$n-1))

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
color.btwn(1:N,theta.ci[1,],theta.ci[2,],from=1,to=N,col.area=rgb(0,0,0,.2))

# Constant Forecast (of theta):
#y_new <- rep(tail(theta.mean,1),12)
##sd_new <- matrix(theta.ci[,N],nrow=12,ncol=2,byrow=TRUE)
#fut_ind <- (N+1):(N+12)
#lines(fut_ind, y_new, col='steelblue', lwd=3,type='o')
#color.btwn(fut_ind,sd_new[,1],sd_new[,2],from=N+1,to=N+12,
#           col.area=rgb(0,0,1,.2))


