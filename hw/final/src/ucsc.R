set.seed(223)
source("../../hw4/src/o2season.R",chdir=TRUE)
library(rcommon)
library(fields) # quilt.plot
library(doMC)
registerDoMC( as.numeric(system("nproc",intern=TRUE)) )

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
grid.res <- 30
delta.grid <- expand.grid(seq(.1,.99,len=grid.res), seq(.1,.99,len=grid.res))

system.time( # much faster than sequential...
ll <- foreach(i=1:grid.res^2, .combine='c') %dopar% { # 
  d.pair <- as.numeric(delta.grid[i,])
  filt <- o2season(ucsc,p=12,h=c(1:6),m0=m0,C0=C0,d0=1,n0=1,delta=d.pair)
  ll_pred_density(filt)
})

par.mar <- par()$mar
par(mar=c(4,4,2,5),las=1)
quilt.plot(delta.grid[,1], delta.grid[,2], ll, cex=2, 
           main='Log-likelihood of Predictive Density',
           col.main='grey30',
           fg='grey',
           xlab=expression(delta~"trend"), 
           ylab=expression(delta~"seasonal"))
par(mar=par.mar, las=0)
delta.hat <- as.numeric(delta.grid[which.max(ll),])
delta.hat 

# Sensitive to start value
#opt <- function(delta) {
#  if (any(delta <= .8) || any(delta >= 1) )
#    Inf 
#  else {
#    filt <- o2season(ucsc,p=12,h=c(1:6),m0=m0,C0=C0,d0=1,n0=1,delta=delta)
#    -ll_pred_density(filt)
#  }
#}
#
#delta.hat <- optim(c(.9,.9), opt)
### End of choose delta

filt <- o2season(ucsc,p=12,h=c(1:6),
                 m0=m0,C0=C0,d0=1,n0=1,delta=delta.hat)
fc <- forecast(filt,nAhead)
filt.ci <- sapply(filt$param, function(p)
                  p$f + sqrt(p$Q) * qt(c(.025,.975),df=p$n-1))
fc.ci <- sapply(1:nAhead, function(i)
                fc$f[i] + sqrt(fc$Q[i]) * qt(c(.025,.975),df=fc$n-1))


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
lines(1:N, ucsc, col='grey30',lwd=1)
# Filtering 
lines(sapply(filt$param,function(p) t(filt$FF) %*% p$m),type='l',col='blue',lwd=2)
color.btwn(1:N,filt.ci[1,],filt.ci[2,],from=1,to=N,col.area=rgb(0,0,1,.2))
# Forecast
lines((N+1):(N+nAhead), fc$f,lty=1,lwd=2,col='red')
color.btwn((N+1):(N+nAhead),fc.ci[1,],fc.ci[2,],from=1,to=N+nAhead,col.area=rgb(1,0,0,.2))

# Plot of the filtered trend 1:N
lines(1:N,
      sapply(filt$param, function(p) t(filt$F[1:2])%*%p$m[1:2]))


# Plot of Harmonics
#plot(0,0,type='n',ylim=c(-20,20),xlim=c(1,N))
#for (i in c(1,4)) lines(1:N,
#     sapply(filt$param, function(p) 
#            t(filt$F[(1:2)+2*i])%*%p$m[(1:2)+2*i]), type='l')
