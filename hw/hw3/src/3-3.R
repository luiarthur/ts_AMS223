library(rcommon)
source("sample_w.R")

dat <- ts(read.table("../dat/soi.dat", skip=16, header=FALSE)[,1])

n <- length(dat)
stopifnot(n == 540 && dat[1] == 2.993 && dat[n] == -1.006)

plot(dat)
x <- spec.pgram(dat,plot=FALSE)
plot(x)
#plot(x$freq, log(x$spec)/log(10), type='l'); abline(h=4) # same
#spec.pgram(dat)#; abline(h=4)

w <- sample_w(dat, B=10000, scale=pi/.5)
plotPost(w,trace=FALSE,xlim=c(0,.5),cex.l=2, main='posterior for '~omega)
plotPost(2*pi/w,trace=FALSE,xlim=c(0,200),cex.l=2, main=expression('posterior for '~lambda))

plot(dat,bty='n')
abline(v=(1:10)*mean(2*pi/w),lwd=2,col='grey')

# OLD
#y <- dat
#k <- seq(1, floor(n/2 - .5), by=1)
#a.hat <- sapply(k, function(ki) 
#                2/n * sum( y * cos(2*pi*ki/n * (1:n)) ))
#
#b.hat <- sapply(k, function(ki) 
#                2/n * sum( y * sin(2*pi*ki/n * (1:n)) ))
#
#pgram <- (a.hat^2 + b.hat^2) * n / 2
#w <- 2*pi*k/n
#plot(2*pi*k/n, pgram, type='l', pch=16)
#plot(x$freq, x$spec, type='l')
#plot(2*pi*k/n, log(pgram), type='l', pch=16)
