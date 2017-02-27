library(dlm)
dlmFilterDF <- function(y,mod,debug=FALSE,simplify=FALSE,delta=.8) {
  G <- mod$GG
  P <- G %*% (mod$C0) %*% t(G)
  W(mod) <- P / delta 
  dlmFilter(y,mod,debug,simplify)
}

n <- 100
sea <- sin(1:n)
x <- seq(-10,10,length=n)
trend <- (.2*x)^2
y <- sea + trend# + rnorm(n,0,1)

plot(y,type='l')
abline(v=2*pi * (0:n) + 1)

k <- 2; p <- 2*pi
ntrain <- 60; dV <- 1
#dW <- 1

mod <- dlmModPoly(k,dV=dV, dW=c( rep(dW,k-1), 1)) + 
           dlmModSeas(p,dV=dV, dW=c( rep(dW,p-2), 1))
#filt <- dlmFilter(y[1:ntrain], mod)

filt <- dlmFilterDF(y[1:ntrain], mod, delta=.85)
s <- dlmSmooth(filt)

fut <- dlmForecast(filt,nAhead=n-ntrain)

#plot(beet,type='l',col='steelblue',xlim=c(0,N+24),ylim=c(0,100),lwd=2)
par(mfrow=c(2,1),mar=c(3,4,1,1))
plot(y,type='l',col='steelblue',xlim=c(0,n),ylim=range(y),lwd=2)
lines(c(s$s[-1,1],fut$a),lty=2)
abline(v=ntrain,col='grey')

plot(y,type='l',col='steelblue',xlim=c(0,n),ylim=range(y),lwd=2)
lines(c(filt$f,fut$f),lty=2,col='grey30')
abline(v=ntrain,col='grey')
par(mfrow=c(1,1))

