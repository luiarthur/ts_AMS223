dat <- ts(read.table("../dat/soi.dat", skip=16, header=FALSE)[,1])

n <- length(dat)
stopifnot(n == 540 && dat[1] == 2.993 && dat[n] == -1.006)

#curve(cos(1*x),from=-2*pi,to=2*pi,lwd=2)
#curve(cos(.5*x),from=-2*pi,to=2*pi,lwd=2,col='blue',add=TRUE)
#curve(cos(2*x),from=-2*pi,to=2*pi,lwd=2,col='red',add=TRUE)

plot(dat)

par(mfrow=c(2,1))
acf(dat)
pacf(dat)
par(mfrow=c(1,1))

k <- seq(1, floor(n/2 - .5), by=1)
y <- dat

a.hat <- sapply(k, function(ki) 
                2/n * sum( y * cos(2*pi*ki/n * (1:n)) ))

b.hat <- sapply(k, function(ki) 
                2/n * sum( y * sin(2*pi*ki/n * (1:n)) ))

pgram <- (a.hat^2 + b.hat^2) * n / 2
w <- 2*pi*k/n
plot(2*pi*k/n, pgram, type='o', pch=16)
plot(2*pi*k/n, log(pgram), type='o', pch=16,type='l')
spec.pgram(dat)
#plot(n/k, pgram * w*k/n, type='o', pch=16)
