dat <- read.csv("../dat/googletrendsUCSC.csv")
source("pgram.R")
library(rcommon)

t_axis <- levels(dat[,1])
ucsc <- dat[,2]
N <- length(ucsc)
total.years <- round(N/12)
ind <- c(0,seq(12,N,by=12))
label <- c('2004', sapply(t_axis[ind],function(x)substr(x,1,4)))

# Plot of data
plot(0,0, xlim=c(0,N), ylim=c(0,100), type='n',bty='n',fg='grey',xaxt='n',
     xlab='Year',ylab='Google Volume Index',las=2,
     main='Google Trend – UCSC Websearches',col.main='grey30')
axis(1,fg='grey',at=ind,label=label,las=1)
abline(v=ind,col='grey80',lty=2)
lines(1:N, ucsc, col='grey30')

# First differences
ucsc_diff1 <- diff(ucsc)

out <- my.pgram(ucsc_diff1)
plot(out$omega,out$log,type='l',main=expression('log posterior of '~omega),
     ylab='log posterior',xlab=expression(omega))
plot(out$lam,out$log,type='l',main=expression('log posterior of '~lambda),
     xlim=c(2,14), ylab='log posterior',xlab=expression(lambda))

plot(ucsc_diff1,type='l')
abline(v=seq(2,N,by=6),lty=2,col='grey')

plot(out$omega, out$Iw, type='l', main='periodogram')
