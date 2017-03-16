library(rcommon)
source('o2season.R')
gas <- read.table("../dat/gas.dat",header=FALSE)[,1]


#filt <- o2season(gas,h=c(1,3,4),p=12,d=c(.9,.95),m0=rep(0,8),C0=diag(8),n0=1,d0=1)
filt <- o2season(gas,h=1:6,p=12,d=c(.9,.95),m0=rep(0,12+2),C0=diag(12+2),n0=1,d0=1)
filt <- o2season(gas,h=1:6,p=12)
fc <- forecast(filt)


plot(gas,type='b')
lines(sapply(filt$param,function(p) t(filt$FF) %*% p$m),type='l',col='blue',lty=2)


