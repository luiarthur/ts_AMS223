library(dlm)
library(rcommon)
comp <- read.csv("../dat/bach_beet.csv", skip=5)
col.bach <- "orange"

times <- levels(comp[,1])
bach <- comp[,2]
N <- length(bach)
ind <- seq(1,N,by=12)
total.years <- round(N/12)


# DLM:
nTrain <- 12*9; p <- 12; k <- 3; dV <- 1
bachMod <- dlmModPoly(k, dV=dV, dW=c( rep(0,k-1), 0)) + 
           dlmModSeas(p, dV=dV, dW=c( rep(0,p-2), 0))

bachFilt <- dlmFilter(bach[1:nTrain], bachMod)
bachFuture <- dlmForecast(bachFilt,nAhead=N-nTrain)
bachSmooth <- dlmSmooth(bachFilt)

plot(0,0, xlim=c(0,N), ylim=c(0,100), type='n',bty='n',fg='grey',xaxt='n',
     xlab='',ylab='Google Volume Index',las=2)
axis(1,fg='grey',at=ind,label=sapply(times[ind],function(x)substr(x,1,4)),las=1)
abline(v=seq(1,N,by=6),col='grey80',lty=3)
abline(v=ind,col='grey80',lty=2)

future_ind <- (nTrain+1):N
lines(1:nTrain, bach[1:nTrain],type='l',lwd=3,pch=20,cex=.5,col=col.bach)
lines(future_ind, bach[future_ind],type='l',lwd=3,pch=20,cex=.5,col=col.bach,lty=3)
lines(c(bachFilt$f,bachFuture$f),lty=1,col='grey30')
lines(c(bachSmooth$s[-1,1],bachFuture$a[,1]), col='grey30')

Q <- sapply(bachFuture$Q, function(x) x[[1]])
ci.lower <- bachFuture$f[,1] - sqrt(Q) * 1.96
ci.upper <- bachFuture$f[,1] + sqrt(Q) * 1.96
color.btwn(future_ind, ci.upper, ci.lower, from=0, to=1000,col.area=rgb(0,0,0,.2))

