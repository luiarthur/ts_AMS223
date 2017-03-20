set.seed(223)
source('ffbs/ffbs.R',chdir=TRUE)
source("../../hw4/src/o2season.R",chdir=TRUE)
library(rcommon)
library(xtable)

dat <- read.csv("../../midterm/dat/googletrendsUCSC.csv")

t_axis <- levels(dat[,1])
ucsc <- dat[,2]
N <- length(ucsc)
total.years <- round(N/12)
ind <- c(0,seq(12,N,by=12))
label <- c('2004', sapply(t_axis[ind],function(x)substr(x,1,4)))
nAhead <- 12*1
ci <- .9; ci.level <- 1-ci
ci.range <- c(ci.level/2, ci+ci.level/2)


source('ffbs/ffbs.R',chdir=TRUE)
system.time(
out <- ffbs(ucsc,q=2,B=1000,burn=500,printFreq=100)
)
mod <- dlm(m0=c(1,0),C0=diag(2),FF=matrix(1:0,nrow=1),V=1,GG=diag(2),W=diag(2)) 

alpha <- sapply(out$samps, function(s) s$alpha)
beta <- sapply(out$samps, function(s) s$beta)
plotPosts(cbind(alpha,beta))

plotPosts(phi <- t(sapply(out$samps, function(s) s$phi)))

v <- sapply(out$samps, function(s) s$v)
w <- sapply(out$samps, function(s) s$w)
plotPosts(cbind(v,w))

# Plot Theta
theta <- to.arr(lapply(out$samps, function(s) s$theta))
theta.mean <- apply(theta, 1:2, mean)
theta.ci <- apply(theta, 1:2, quantile, c(.05,.95))

colnames(theta.mean) <- paste0('theta', 1:2)
plot.ts(theta.mean,type='l')

# Prediction
plot(ucsc,type='b',pch=16,col='grey30')
pred <- sapply(out$samps, function(s) s$a + s$b*1:N)
lines(apply(pred,1,mean)+theta.mean[-1,1],col='blue',lwd=2)
#color.btwn.mat(1:N, t(apply(pred,1,quantile,c(.05,.95))))
