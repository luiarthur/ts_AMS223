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
