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
delta_grid_size <- 100
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


# Plots
pdf('../tex/img/inference.pdf',w=13,h=7)
plot(0,0, xlim=c(0,N+12), ylim=c(0,100), type='n',bty='n',
     fg='grey',xaxt='n',
     xlab='Year',ylab='Google Volume Index',las=2,
     main='Google Trend  -  UCSC Websearches',col.main='grey30')

axis(1,fg='grey',at=c(ind,tail(ind,1)+12),
     label=c(label,tail(strtoi(label),1)+1),las=1)
abline(v=c(ind,tail(ind,1)+12),col='grey80',lty=2)
#lines(1:N, ucsc, col='grey30',lwd=1)

# One-step Ahead Forecast y_t | D_{t-1}
theta.mean <- sapply(filt$param, function(p) p$m)
#lines(1:N,theta.mean,lty=1,lwd=3,col='orange')
y.ci <- sapply(filt$param, function(p) 
               p$f + sqrt(p$Q) * qt(c(.025,.975),df=p$n-1))
color.btwn(1:N,y.ci[1,],y.ci[2,],from=1,to=N,col.area=rgb(1,.6,0,.4))


# Filtering Line theta_t | D_t
theta.ci <- sapply(filt$param, function(p) 
                   p$m + sqrt(p$C) * qt(c(.025,.975),df=p$n))
#lines(1:N,theta.mean,lty=2,lwd=3,col='blue')
color.btwn(1:N,theta.ci[1,],theta.ci[2,],from=1,to=N,col.area=rgb(0,0,1,.2))


# Forecast (of y):
y_new <- forecast(filt,12)
fut_ind <- (N+1):(N+12)
#points(fut_ind, y_new$f, col='darkgreen', pch=3,lwd=3,cex=1)
new.ci <-  sapply(1:12, function(i)
                  y_new$f[i] + sqrt(y_new$Q[i]) * qt(c(.025,.975),df=y_new$n))
color.btwn(fut_ind,new.ci[1,],new.ci[2,],from=N+1,to=N+12,
           col.area=rgb(0,.5,0,.5))

# Forecast (of theta):
#points(fut_ind, y_new$a, col='yellow', type='b',lty=2, pch=20,lwd=2,cex=.7)
tf.ci <-  sapply(1:12, function(i)
                  y_new$a[i] + sqrt(y_new$R[i]) * qt(c(.025,.975),df=y_new$n))
color.btwn(fut_ind,tf.ci[1,],tf.ci[2,],from=N+1,to=N+12,
           col.area=rgb(1,1,0,.5))

# Smoothing Line \theta_t | D_T
s <- smoothing(filt)
#lines(s$a,col='red',lwd=3)
s.ci <- sapply(1:N, function(i) s$a[i] + sqrt(s$V[i]) * qt(c(.025,.975),df=N))
color.btwn(1:N, s.ci[1,], s.ci[2,], from=1, to=N, col.area=rgb(1,0,0,.3))


# Redraw point estimates
lines(1:N, ucsc, col='grey30',lwd=1)
lines(1:N,theta.mean,lty=1,lwd=3,col='orange')
lines(1:N,theta.mean,lty=2,lwd=3,col='blue')
lines(s$a,col='red',lwd=3)
lines(fut_ind, y_new$f, col='darkgreen', lwd=10)
points(fut_ind, y_new$a, col='yellow', type='b',lty=2, pch=20,lwd=2,cex=.7)



legend('bottomleft', 
       legend=c('Smoothing', 'Filtering', 'One-step Ahead', 
                '12-step Forecast (y)', 
                '12-step Forecast (theta)', 
                'Data'), bty='n', cex=2, 
       text.col=c('red','blue','orange',rgb(0,.5,0), 'gold', 'grey30'),
       #col=c(NA,NA,NA,NA,rgb(1,.9,0),NA),
       col=c(NA,NA,NA,NA,'gold',NA),
       pch=c(NA,NA,NA,NA,20,NA),
       pt.cex=c(NA,NA,NA,NA,4,NA),
       text.font=2)

dev.off() # end of inference
