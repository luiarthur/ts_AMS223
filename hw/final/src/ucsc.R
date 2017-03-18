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
ci <- .9; ci.level <- 1-ci
ci.range <- c(ci.level/2, ci+ci.level/2)

# Choose delta
system.time( # takes about a minute: c(.9, .95)
  delta.hat <- optim.delta(ucsc,h=1:6,p=12,m0=m0,grid.res=30,
                           lower=.1,upper=1,N=20,ncore=8,gen.plot=TRUE,
                           col.mark='grey')
)


# Fit Model
filt <- o2season(ucsc,p=12,h=c(1:6),m0=m0,delta=delta.hat)

# Forecast Distribution
fc <- forecast(filt,nAhead)
fc.ci <- sapply(1:nAhead, function(i)
                fc$f[i] + sqrt(fc$Q[i]) * qt(ci.range,df=fc$n-1))

# One Step Ahead
one.step.ahead.mean <- sapply(filt$param,function(p) p$f)
one.step.ahead.ci <- sapply(filt$param,function(p) 
                           p$f + sqrt(p$Q)*qt(ci.range, df=p$n-1))

# Filtering Trend
filt.trend.mean <- sapply(filt$param, function(p) p$m[1])
filt.trend.ci <- sapply(filt$param, function(p) 
                        p$m[1] + sqrt(p$R[1,1])*qt(ci.range, df=p$n-1))

# Filtering Seasonals

# Smoothing (W&H Corollary 4.4)
sm <- smoothing(filt)
sm.trend.mean <- sapply(sm$a, function(a) a[1])
sm.trend.ci <- rbind(sm.trend.mean,sm.trend.mean) + 
               sapply(sm$V, function(V) 
                     sqrt(V[1,1])*qt(ci.range, df=length(sm$a)))


# Smoothing Seasonals

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
lines(1:N, ucsc, col='grey30',lwd=1,type='p',pch=16)

# One-step Ahead
lines(one.step.ahead.mean, col='red', lwd=2)
color.btwn.mat(1:N,t(one.step.ahead.ci),col.area=rgb(1,0,0,.2))

# Forecast
lines((N+1):(N+nAhead), fc$f,lty=2,lwd=2,col='red')
color.btwn.mat((N+1):(N+nAhead),t(fc.ci),col.area=rgb(1,0,0,.2))

# Filtering Trend
lines(filt.trend.mean, col='blue', lwd=2)
color.btwn.mat(1:N,t(filt.trend.ci),from=1,to=N,col.area=rgb(0,0,1,.2))

# Smoothing Trend
lines(sm.trend.mean,type='l',col='orange',lwd=2)
color.btwn.mat(1:N,t(sm.trend.ci),col.area=rgb(1,1,0,.3))



# Plot of Harmonics
#plot(0,0,type='n',ylim=c(-20,20),xlim=c(1,N))
#for (i in c(1,4)) lines(1:N,
#     sapply(filt$param, function(p) 
#            t(filt$F[(1:2)+2*i])%*%p$m[(1:2)+2*i]), type='l')
