set.seed(223)
source("../../hw4/src/o2season.R",chdir=TRUE)
library(rcommon)

dat <- read.csv("../../midterm/dat/googletrendsUCSC.csv")

t_axis <- levels(dat[,1])
ucsc <- dat[,2]
N <- length(ucsc)
total.years <- round(N/12)
ind <- c(0,seq(12,N,by=12))
label <- c('2004', sapply(t_axis[ind],function(x)substr(x,1,4)))
nAhead <- 12*1
m0 <- c(84,-.3,rep(0,2*6))
C0 <- diag(250,2+2*6)

# Choose delta
system.time( # takes about a minute: c(.9, .95)
  delta.hat <- optim.delta(ucsc,h=1:6,p=12,m0=m0,C0=C0,
                           lower=.1,upper=1,N=20,ncore=8)
)


# Fit Model
filt <- o2season(ucsc,p=12,h=c(1:6),
                 m0=m0,C0=C0,d0=1,n0=1,delta=delta.hat)
fc <- forecast(filt,nAhead)
filt.ci <- sapply(filt$param, function(p)
                  p$f + sqrt(p$Q) * qt(c(.025,.975),df=p$n-1))
fc.ci <- sapply(1:nAhead, function(i)
                fc$f[i] + sqrt(fc$Q[i]) * qt(c(.025,.975),df=fc$n-1))
sm <- smoothing(filt)

######################3

# PLOTS
plot(0,0, xlim=c(0,N+nAhead), ylim=c(0,100), type='n',bty='n',
     fg='grey',xaxt='n',
     xlab='Year',ylab='Google Volume Index',las=2,
     main='Google Trend  -  UCSC Websearches',col.main='grey30')

axis(1,fg='grey',at=c(ind,tail(ind,1)+nAhead),
     label=c(label,tail(strtoi(label),1)+1),las=1)
abline(v=c(ind,tail(ind,1)+nAhead),col='grey80',lty=2)

# Data
lines(1:N, ucsc, col='grey30',lwd=1,type='b',pch=16)
# Filtering 
lines(sapply(filt$param,function(p) t(filt$FF) %*% p$m),type='l',col='blue',lwd=2)
color.btwn(1:N,filt.ci[1,],filt.ci[2,],from=1,to=N,col.area=rgb(0,0,1,.2))
# Forecast
lines((N+1):(N+nAhead), fc$f,lty=1,lwd=2,col='red')
color.btwn((N+1):(N+nAhead),fc.ci[1,],fc.ci[2,],from=1,to=N+nAhead,col.area=rgb(1,0,0,.2))

# Plot of the filtered trend 1:N
lines(1:N,
      sapply(filt$param, function(p) p$m[1]))

# Smoothing
lines(sapply(sm$a,function(a) a[1]),type='l',col='orange',lwd=2)



# Plot of Harmonics
#plot(0,0,type='n',ylim=c(-20,20),xlim=c(1,N))
#for (i in c(1,4)) lines(1:N,
#     sapply(filt$param, function(p) 
#            t(filt$F[(1:2)+2*i])%*%p$m[(1:2)+2*i]), type='l')
