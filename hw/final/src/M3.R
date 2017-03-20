set.seed(223)
source("../../hw4/src/o2season.R",chdir=TRUE)
source('ffbs/ffbs.R',chdir=TRUE)
library(rcommon)
library(xtable)

dat <- read.csv("../../midterm/dat/googletrendsUCSC.csv")

t_axis <- levels(dat[,1])
ucsc <- dat[,2]
N <- length(ucsc)
total.years <- round(N/12)
ind <- c(0,seq(12,N,by=12))
label <- c('2004', sapply(t_axis[ind],function(x)substr(x,1,4)))
nAhead <- 12*1
ci <- .9; ci.level <- 1-ci
ci.range <- c(ci.level/2, ci+ci.level/2)


system.time(
out <- ffbs(ucsc,q=2,B=1000,burn=500,printFreq=100)
)
mod <- dlm(m0=c(1,0),C0=diag(2),FF=matrix(1:0,nrow=1),V=1,GG=diag(2),W=diag(2)) 

alpha <- sapply(out$samps, function(s) s$alpha)
beta <- sapply(out$samps, function(s) s$beta)
pdf('../tex/img/ab.pdf')
plotPosts(cbind(alpha,beta))
dev.off()

pdf('../tex/img/phi.pdf')
plotPosts(phi <- t(sapply(out$samps, function(s) s$phi)))
dev.off()

v <- sapply(out$samps, function(s) s$v)
w <- sapply(out$samps, function(s) s$w)
pdf('../tex/img/vw.pdf')
plotPosts(cbind(v,w))
dev.off()

# Plot Theta
theta <- to.arr(lapply(out$samps, function(s) s$theta))
theta.mean <- apply(theta, 1:2, mean)
theta.ci <- apply(theta, 1:2, quantile, c(.05,.95))

colnames(theta.mean) <- paste0('theta', 1:2)
pdf('../tex/img/theta.pdf')
plot.ts(theta.mean,type='l', main=expression("Mean"~theta))
dev.off()

x.mean <- theta.mean[-1,1]
x.ci <- theta.ci[,-1,2]
pdf('../tex/img/x.pdf')
plot(x.mean,type='l',col='grey30',lwd=2,bty='n',fg='grey',ylab='x')
color.btwn.mat(1:N,t(x.ci))
dev.off()

# Prediction
trend <- sapply(out$samps, function(s) s$a + s$b*1:N)
pred.mean <- apply(trend,1,mean)+theta.mean[-1,1]
pred.ci <- apply(trend,1,quantile,c(.05,.95)) + theta.ci[,-1,2]

pdf('../tex/img/M3.pdf')
plot(0,0, xlim=c(0,N+nAhead), ylim=c(0,100), type='n',bty='n',
     fg='grey',xaxt='n',
     xlab='Year',ylab='Google Volume Index',las=2,
     main='Google Trend  -  UCSC Websearches',col.main='grey30')
axis(1,fg='grey',at=c(ind,tail(ind,1)+nAhead),
     label=c(label,tail(strtoi(label),1)+1),las=1)
abline(v=c(ind,tail(ind,1)+nAhead),col='grey80',lty=2)
# Data
lines(1:N, ucsc, col='grey30',lwd=1,type='p',pch=16)
# Pred
lines(pred.mean,col='red',lwd=2)
color.btwn.mat(1:N,t(pred.ci),col=rgb(1,0,0,.2))
# Forecast
fc <- forecast(out,nAhead=nAhead)
fc.mean <- apply(fc,1,mean)
fc.ci <- apply(fc,1,quantile,c(.05,.95))
lines( (N+1):(N+nAhead), fc.mean, col='red', lwd=2)
color.btwn.mat((N+1):(N+nAhead),t(fc.ci),col=rgb(1,0,0,.2))
dev.off()

