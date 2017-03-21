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


pdf('../tex/img/pacf.pdf',w=13,h=7)
pacf(ucsc)
dev.off()

system.time( # 2000 iterations: quick for q=2,  11 minus (q=15)
out <- ffbs(ucsc,q=2,B=200,burn=2000,printFreq=100)
)

alpha <- sapply(out$samps, function(s) s$alpha)
beta <- sapply(out$samps, function(s) s$beta)
pdf('../tex/img/ab.pdf')
plotPosts(cbind(alpha,beta))
dev.off()

#pdf('../tex/img/phi.pdf')
#plotPosts(phi <- t(sapply(out$samps, function(s) s$phi)))
#dev.off()

v <- sapply(out$samps, function(s) s$v)
w <- sapply(out$samps, function(s) s$w)
pdf('../tex/img/vw.pdf')
plotPosts(cbind(v,w))
dev.off()

# Plot Theta
theta <- to.arr(lapply(out$samps, function(s) s$theta))
theta.mean <- apply(theta, 1:2, mean)
colnames(theta.mean) <- paste0('theta', 1:out$q)
theta.ci <- apply(theta, 1:2, quantile, c(.05,.95))

#pdf('../tex/img/theta.pdf')
#plot.ts(theta.mean,type='l', main=expression("Mean"~theta))
#dev.off()

x.mean <- theta.mean[-1,1]
x.ci <- theta.ci[,-1,1]
pdf('../tex/img/x.pdf',w=13,h=7)
plot(1:N,x.mean,type='l',col='grey30',lwd=2,bty='n',fg='grey',ylab='x')
color.btwn.mat(1:N,t(x.ci))
dev.off()

# Prediction
trend <- sapply(out$samps, function(s) s$a + s$b*1:N)
pred.mean <- apply(trend,1,mean)+theta.mean[-1,1]
pred.ci <- apply(trend,1,quantile,c(.05,.95)) + theta.ci[,-1,2]

pdf('../tex/img/M3.pdf',w=13,h=7)
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
lines( (N+1):(N+nAhead), fc.mean, col='red', lwd=2, lty=2)
color.btwn.mat((N+1):(N+nAhead),t(fc.ci),col=rgb(1,0,0,.2))
dev.off()

### Eigen
Groot <- G.roots(out)
Groot.mod.mean <- apply(Groot$mod,1,mean)
Groot.arg.mean <- apply(Groot$arg,1,mean)
Groot.mod.ci <- apply(Groot$mod,1,quantile,c(.05,.95))
Groot.arg.ci <- apply(Groot$arg,1,quantile,c(.05,.95))

pdf('../tex/img/root.pdf',w=13,h=7)
par(mfrow=c(2,1),mar=mar.ts,oma=oma.ts)
plot(Groot.arg.mean,ylim=range(Groot.arg.ci),xaxt='n',ylab='Frequency')
add.errbar(t(Groot.arg.ci))

plot(Groot.mod.mean,ylim=range(Groot.mod.ci),ylab='modulus')
add.errbar(t(Groot.mod.ci))
par(mfrow=c(1,1),mar=mar.default,oma=oma.default)
dev.off()


