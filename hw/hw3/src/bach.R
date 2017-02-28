library(dlm)
comp <- read.csv("../dat/bach_beet.csv", skip=5)
col.bach <- "orange"

times <- levels(comp[,1])
bach <- comp[,2]
N <- nrow(comp)
ind <- seq(1,N,by=12)
total.years <- round(N/12)


# DLM:
nTrain <- 12*8; p <- 12; k <- 2; dV <- 1
bachMod <- dlmModPoly(k,dV=dV, dW=c( rep(1,k-1), 0)) + 
           dlmModSeas(p,dV=dV, dW=c( rep(1,p-2), 0))

bachFilt <- dlmFilter(bach[1:nTrain], bachMod)
bachFuture <- dlmForecast(bachFilt,nAhead=N-nTrain)

plot(0,0, xlim=c(0,N), ylim=c(0,110), type='n',bty='n',fg='grey',xaxt='n',
     xlab='',ylab='Score',las=2)
axis(1,fg='grey',at=ind,label=sapply(times[ind],function(x)substr(x,1,4)),las=1)
abline(v=seq(1,N,by=6),col='grey80',lty=3)
abline(v=ind,col='grey80',lty=2)

future_ind <- (nTrain+1):N
lines(1:nTrain, bach[1:nTrain],type='l',lwd=3,pch=20,cex=.5,col=col.bach)
lines(future_ind, bach[future_ind],type='l',lwd=3,pch=20,cex=.5,col=col.bach,lty=3)
lines(c(bachFilt$f,bachFuture$f),lty=3,col='grey30',lwd=2)

Q <- sapply(bachFuture$Q, function(x) x[[1]])
lines(future_ind,bachFuture$f[,1] - sqrt(Q) * 1.96, lty=2)
lines(future_ind,bachFuture$f[,1] + sqrt(Q) * 1.96, lty=2)

#bachFuture$newObs[[1]][,1]
#bachFuture <- dlmForecast(bachFilt,nAhead=N-nTrain,sampleNew=1000)
#pred <- sapply(bachFuture$newObs, function(newobs) newobs[,1])
#ci <- apply(pred,1,quantile,c(.025,.975))
#lines(ind, ci[1,])
#lines(ind, ci[2,])
#lines(ind, apply(pred,1,mean), col='blue',lwd=2)

