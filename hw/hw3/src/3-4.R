library(rcommon)
source("sample_w.R")
data(lh)

spec.pgram(lh)

w <- sample_w(lh, B=10000, scale=pi/.5)
plotPost(w,trace=FALSE,legend.pos='topright',
         main='posterior for '~omega)
plotPost(2*pi/w,trace=FALSE,cex.l=2,legend.pos='topright',
         main=expression('posterior for '~lambda))

plot(lh,bty='n')
abline(v=(1:10)*mean(2*pi/w),lwd=2,col='grey')

