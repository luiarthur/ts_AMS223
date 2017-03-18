set.seed(223)
library(dlm)
library(rcommon)

dat <- read.csv("../../midterm/dat/googletrendsUCSC.csv")
ucsc <- dat[,2]

dlmMod <- dlmModPoly(2) + dlmModSeas(12)
f <- dlmFilter(ucsc,dlmMod)
s <- dlmSmooth(f)

plot(ucsc,type='l',ylim=c(0,100))
lines(f$a[,1],lwd=2,col='blue')
lines(s$s[,1],lwd=2,col='red')
