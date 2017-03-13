source("fourier_coef.R")
milk <- read.table("../dat/milk.dat")[[1]]

plot(milk,type='b')

fc <- fourier_coef(milk)
x <- fourier_trans(fc)

plot(x,pch=4,lwd=3,type='l')
points(x,pch=4,lwd=3)


plot(fourier_trans(fc,n=length(milk)*3),type='b')
points(milk,col='blue',pch=20,cex=2)

#s <- 3
#p <- 12
#x <- 0:(s*p)
#y <- cos(2*pi*x/p)
#plot(x,y,type='l'); abline(v=(0:s)*p)

# Example:
y <- c(1.65, 0.83, 0.41, -0.70, -0.47, 0.40, -0.05, -1.51, -0.19, -1.02, -0.87, 1.52)
fourier_coef(y)
