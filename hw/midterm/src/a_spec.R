dat <- read.csv("../dat/googletrendsUCSC.csv")
source("pgram.R")
library(rcommon)

t_axis <- levels(dat[,1])
ucsc <- dat[,2]
N <- length(ucsc)
total.years <- round(N/12)
ind <- c(0,seq(12,N,by=12))
label <- c('2004', sapply(t_axis[ind],function(x)substr(x,1,4)))

# First differences
ucsc_diff1 <- diff(ucsc)

# Plot of data
pdf('../tex/img/ucsc.pdf')
par(mfrow=c(2,1))
plot(0,0, xlim=c(0,N), ylim=range(ucsc), type='n',bty='n',fg='grey',xaxt='n',
     xlab='Year',ylab='Google Volume Index',las=2,
     main='Google Trend - UCSC Websearches',col.main='grey30')
axis(1,fg='grey',at=ind,label=label,las=1)
abline(v=ind,col='grey80',lty=2)
lines(1:N, ucsc, col='grey30')

plot(ucsc_diff1, xlim=c(0,N), ylim=c(-30,30), type='l',bty='n',fg='grey',xaxt='n',
     xlab='Year',ylab='Google Volume Index',las=2,col='grey30',
     main='UCSC Websearches - First Differences',col.main='grey30')
axis(1,fg='grey',at=ind,label=label,las=1)
abline(v=ind,col='grey80',lty=2)
par(mfrow=c(2,1))
dev.off()


out <- my.pgram(ucsc_diff1)
pdf('../tex/img/spec.pdf')
par(mfrow=c(2,1))
plot(out$omega,out$log,type='l',main=expression('log posterior of '~omega),
     ylab='log posterior',xlab=expression(omega),bty='n',fg='grey',
     col='grey30',lwd=2,las=1)
plot(out$lam,out$log,type='l',main=expression('log posterior of '~lambda),
     xlim=c(2,14), ylab='log posterior',xlab=expression(lambda),
     col='grey30',lwd=2,fg='grey',bty='n',las=1)
par(mfrow=c(1,1))
dev.off()

#plot(ucsc_diff1,type='l')
#abline(v=seq(2,N,by=6),lty=2,col='grey')
#
#plot(out$omega, out$Iw, type='l', main='periodogram')
