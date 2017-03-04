kfilter <- function(y,m0=0,C0=1,n0=1,d0=1,delta=.9) {
  N <- length(y)

  param <- as.list(1:N)
  prior <- list(m=m0, C=C0, n=n0, d=d0)

  for (i in 1:N) {
    prev <- if(i>1) param[[i-1]] else prior

    W <- prev$C * (1-delta) / delta
    R <- prev$C + W
    Q <- R + 1

    f <- prev$m
    m <- prev$m + (R/Q) * (y[i]-f)
    C <- R - R^2 / Q
    n <- prev$n + 1
    d <- prev$d + (y[i]-f)^2 / Q

    param[[i]] <- list(m=m,C=C,n=n,d=d,Q=Q,R=R,f=f)
  }

  list(y=y, delta=delta, param=param, prior=prior)
}

kfilter.theta <- function(filt,B=1000) {
  sapply(filt$param, function(param) {
    v <-  1 / rgamma(B, param$n/2, rate=param$d/2)
    rnorm(B, param$m, sqrt(v*param$C))
  })
}


# Not correct!!!
ll_pred_density <- function(filt,B=1000) {
  N <- length(filt$y)
  param <- filt$param

  ll <- sapply(1:N, function(i) {
    p <- param[[i]]
    prev <- if (i>1) param[[i-1]] else filt$prior
    v <- 1 / rgamma(B, prev$n/2, rate=prev$d/2)
    dnorm(filt$y[i], p$f, sqrt(v*p$Q), log=TRUE)
  })

  return(apply(ll,1,sum))
}

#forecast <- function(filt,nAhead=1) {
#  N <- length(filt$y)
#
#  samp <- function(param) {
#    oneSamp <- function(dummy) {
#      v <- 1 / rgamma(1, param$n/2, rate=param$d/2)
#      rnorm(1, param$m, sqrt(v*param$Q))
#    }
#
#    sapply(1:B, oneSamp)
#  }
#
#  sapply(filt$param, samp) 
#}
