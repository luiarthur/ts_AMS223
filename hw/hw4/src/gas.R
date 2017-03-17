library(rcommon)
source('o2season.R')
gas <- read.table("../dat/gas.dat",header=FALSE)[,1]


N <- length(gas)
nAhead <- 72
#filt <- o2season(gas,h=1:6,p=12,d=c(.9,.95),m0=rep(0,12+2),C0=diag(12+2),n0=1,d0=1)
#filt <- o2season(gas,h=c(1:5),p=12)
#filt <- o2season(gas,h=c(1:6),p=12)
filt <- o2season(gas,h=c(1,4),p=12)
fc <- forecast(filt,nAhead)
filt.ci <- sapply(filt$param, function(p)
                  p$f + sqrt(p$Q) * qt(c(.025,.975),df=p$n-1))
fc.ci <- sapply(1:nAhead, function(i)
                fc$f[i] + sqrt(fc$Q[i]) * qt(c(.025,.975),df=fc$n-1))

plot(gas,type='p',xlim=c(1,N+nAhead),ylim=range(c(gas,fc.ci)),pch=20,col='grey30')

lines(sapply(filt$param,function(p) t(filt$FF) %*% p$m),type='l',col='blue',lwd=2)
color.btwn(1:N,filt.ci[1,],filt.ci[2,],from=1,to=N,col.area=rgb(0,0,1,.2))

lines((N+1):(N+nAhead), fc$f,lty=2,lwd=2,col='red')
color.btwn((N+1):(N+nAhead),fc.ci[1,],fc.ci[2,],from=1,to=N+nAhead,col.area=rgb(1,0,0,.2))


# Plot of the filtered trend 1:N
lines(1:N,
      sapply(filt$param, function(p) t(filt$F[1:2])%*%p$m[1:2]))

# Plot of Harmonics
plot(0,0,type='n',ylim=c(-3,3),xlim=c(1,N))
for (i in c(4,1)) lines(1:N,
     sapply(filt$param, function(p) 
            t(filt$F[(1:2)+2*i])%*%p$m[(1:2)+2*i]), type='l')
