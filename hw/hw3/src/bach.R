library(dlm)
dlmFilterDF <- function(y,mod,debug=FALSE,simplify=FALSE,delta=.8) {
  G <- mod$GG
  P <- G %*% (mod$C0) %*% t(G)
  W(mod) <- P / delta 
  dlmFilter(y,mod,debug,simplify)
}

comp <- read.csv("../dat/bach_beet.csv", skip=5)

col.bach <- "orange"

times <- levels(comp[,1])
bach <- comp[,2]
N <- nrow(comp)
ind <- seq(1,N,by=12)
total.years <- round(N/12)

plot(0,0, xlim=c(0,N), ylim=c(0,110), type='n',bty='n',fg='grey',xaxt='n',
     xlab='',ylab='Score',las=2)
axis(1,fg='grey',at=ind,label=sapply(times[ind],function(x)substr(x,1,4)),las=1)

abline(v=seq(1,N,by=6),col='grey80',lty=3)
abline(v=ind,col='grey80',lty=2)
lines(bach,type='l',lwd=3,pch=20,cex=.5,col=col.bach)

# DLM:
nTrain <- 12*8; p <- 12; k <- 2
bachMod <- dlmModPoly(k,dV=10) +
           dlmModSeas(p,dV=10)
bachFilt <- dlmFilterDF(bach[1:nTrain], bachMod, delta=1)
bachFuture <- dlmForecast(bachFilt,nAhead=N-nTrain)


plot(bach,type='l',col=col.bach,xlim=c(0,N),ylim=c(0,100),lwd=2)
lines(c(bachFilt$f,bachFuture$f),lty=2,col='grey30')
abline(v=nTrain,col='grey')

