library(rcommon)
source('o2season.R')
gas <- read.table("../dat/gas.dat",header=FALSE)[,1]


N <- length(gas)
nAhead <- 12
ci <- .9; ci.level <- 1-ci
ci.range <- c(ci.level/2, ci+ci.level/2)

#filt <- o2season(gas,h=1:6,p=12,d=c(.9,.95),m0=rep(0,12+2),C0=diag(12+2),n0=1,d0=1)
#filt <- o2season(gas,h=c(1:5),p=12)
#filt <- o2season(gas,h=c(1:6),p=12)
filt <- o2season(gas,h=c(1:6),p=12,delta=c(1,1),m0=c(5,rep(0,12)))
fc <- forecast(filt,nAhead)
# One step ahead forecast
filt.ci <- sapply(filt$param, function(p)
                  p$f + sqrt(p$Q) * qt(c(.05,.95),df=p$n-1))
fc.ci <- sapply(1:nAhead, function(i)
                fc$f[i] + sqrt(fc$Q[i]) * qt(c(.05,.95),df=fc$n-1))

plot(gas,type='p',xlim=c(1,N+nAhead),ylim=range(c(gas,fc.ci)),pch=20,col='grey30')

lines(sapply(filt$param,function(p) t(filt$FF) %*% p$m),type='l',col='blue',lwd=2)
color.btwn(1:N,filt.ci[1,],filt.ci[2,],from=1,to=N,col.area=rgb(0,0,1,.2))

lines((N+1):(N+nAhead), fc$f,lty=2,lwd=2,col='red')
color.btwn((N+1):(N+nAhead),fc.ci[1,],fc.ci[2,],from=1,to=N+nAhead,col.area=rgb(1,0,0,.2))

# Smoothing
s <- smoothing(filt)
lines(1:N, sapply(s$a, function(a) t(filt$F)%*%filt$G%*%a), col='orange',lwd=2)

# Filtering Trend
filt.trend.mean <- sapply(filt$param, function(p) p$m[1])
filt.trend.ci <- sapply(filt$param, function(p) 
                        p$m[1] + sqrt(p$R[1,1])*qt(ci.range, df=p$n-1))

# Plot of the filtered trend 1:N
plot(gas,type='b',pch=16,col='grey')
lines(filt.trend.mean)
color.btwn.mat(1:N,t(filt.trend.ci))

# Filtering Seasonals
filt.harm.mean <- sapply(c(3,5,7,9,11,13),function(h) sapply(filt$param, function(p) p$m[h]))
colnames(filt.harm.mean) <- c(paste("Harmonic", 1:5), "Nyquist")
filt.harm.ci <- lapply(c(3,5,7,9,11,13), function(h) 
                       sapply(filt$param, function(p) p$m[h] + sqrt(p$R[h,h])*
                              qt(ci.range,df=p$n-1)))


# Plot Filtering Harmonics
par(mfrow=c(3,2),mar=mar.ts,oma=oma.ts)
for (i in 1:ncol(filt.harm.mean)) {
  plot(filt.harm.mean[,i],type='l', ylab=colnames(filt.harm.mean)[i],
       xaxt=ifelse(i>=5,'s','n'))
  color.btwn.mat(1:N,t(filt.harm.ci[[i]]))
}
par(mfrow=c(1,1), mar=mar.default, oma=oma.default)
title(main='Filtering Distribution for Harmonics (mean and 90% CI)')



# Plot of Harmonics
#plot(0,0,type='n',ylim=c(-3,3),xlim=c(1,N))
#for (i in c(4,1)) lines(1:N,
#     sapply(filt$param, function(p) 
#            t(filt$F[(1:2)+2*i])%*%p$m[(1:2)+2*i]), type='l')
