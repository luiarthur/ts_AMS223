library(dlm)
dlmFilterDF <- function(y,mod,debug=FALSE,simplify=FALSE,delta=.8) {
  G <- mod$GG
  P <- G %*% (mod$C0) %*% t(G)
  W(mod) <- P / delta 
  dlmFilter(y,mod,debug,simplify)
}

comp <- read.csv("../dat/bach_beet.csv", skip=5)

col.bach <- "orange"
col.beet <- "steelblue"

times <- levels(comp[,1])
bach <- comp[,2]
beet <- comp[,3]
N <- nrow(comp)
ind <- seq(1,N,by=12)
total.years <- round(N/12)

plot(0,0, xlim=c(0,N), ylim=c(0,110), type='n',bty='n',fg='grey',xaxt='n',
     xlab='',ylab='Score',las=2)
axis(1,fg='grey',at=ind,label=sapply(times[ind],function(x)substr(x,1,4)),las=1)

abline(v=seq(1,N,by=6),col='grey80',lty=3)
abline(v=ind,col='grey80',lty=2)
lines(bach,type='l',lwd=3,pch=20,cex=.5,col=col.bach)
lines(beet,type='l',lwd=3,pch=20,cex=.5,col=col.beet)

legend("topleft",bg='white',
       legend=c("Beethoven","Bach"),
       text.col=c(col.beet,col.bach),
       box.col='white',
       text.font=3,
       cex=2)

# DLM:
nTrain <- 12*8; p <- 12; k <- 2
beetMod <- dlmModPoly(k,dV=10) + #, dW=c( rep(1,k-1), 1)) + 
           dlmModSeas(p,dV=10)  #, dW=c( rep(1,p-2), 1))
#beetFilt <- dlmFilter(beet[1:nTrain], beetMod)
beetFilt <- dlmFilterDF(beet[1:nTrain], beetMod, delta=1)
beetSmooth <- dlmSmooth(beetFilt)

beetFuture <- dlmForecast(beetFilt,nAhead=N-nTrain)

#plot(beet,type='l',col='steelblue',xlim=c(0,N+24),ylim=c(0,100),lwd=2)
par(mfrow=c(2,1),mar=c(3,4,1,1))
plot(beet,type='l',col=col.beet,xlim=c(0,N),ylim=c(0,100),lwd=2)
lines(c(beetSmooth$s[-1,1],beetFuture$a),lty=2,col=col.beet)
abline(v=nTrain,col='grey')

plot(beet,type='l',col=col.beet,xlim=c(0,N),ylim=c(0,100),lwd=2)
lines(c(beetFilt$f,beetFuture$f),lty=2,col='grey30')
abline(v=nTrain,col='grey')
par(mfrow=c(1,1))

