source("kfilter.R")

kfilter_t <- function(y,m0=0,C0=1,n0=1,d0=1,delta=.9) {
  N <- length(y)

  param <- as.list(1:N)
  prior <- list(m=m0, C=C0, n=n0, d=d0)

  cond <- kfilter(y,m0,C0,n0,d0,delta)$param

  d <- d0
  n <- n0
  S <- d / n

  # variables that are doubled, are intermediates
  for (i in 1:N) {
    cprev <- if (i>1) cond[[i-1]] else prior
    ccurr <- cond[[i]]

    R <- S * ccurr$R
    Q <- S * ccurr$Q
    m <- ccurr$m
    f <- ccurr$f

    n <- ccurr$n
    d <- ccurr$d
    S <- d / n
    C <- S * ccurr$C

    param[[i]] <- list(m=m,C=C,Q=Q,R=R,f=f)
  }

  list(y=y, delta=delta, param=param, prior=prior)
}

ll_pred_density_t <- function(filt) {
  y <- filt$y
  N <- length(y)
  f <- sapply(filt$param, function(x) x$f)
  Q <- sapply(filt$param, function(x) x$Q)
  z <- (y - f) / sqrt(Q)
  n_prev <- filt$prior$n + seq(0,N-1,by=1)
  sum(dt(z, df=n_prev, log=TRUE))
}


ll_pred_den <- function(y,delta=.9,m0=0,C0=1,n0=1,d0=1) {
  N <- length(y)
  param <- as.list(1:N)
  prior <- list(m=m0,C=C0,n=n0,S=d0/n0)

  for (i in 1:N) {
    prev <- if (i > 1) param[[i-1]] else prior

    W <- prev$C * (1-delta) / delta

    n <- prev$n + 1
    R <- prev$C + W
    Q <- R + prev$S
    f <- prev$m
    A <- R/Q
    e <- y[i] - f
    m <- prev$m + A*e
    S <- prev$S + prev$S/n * (e^2/Q - 1)
    C <- S*A

    param[[i]] <- list(m=m,C=C,n=n,Q=Q,R=R,f=f,S=S)
  }

  z <- sapply(1:N, function(i) 
              (y[i] - param[[i]]$f) / sqrt(param[[i]]$Q))

  DF <- c(n0, head(sapply(param,function(p)p$n),N-1))
  sum(dt(z,df=DF,log=TRUE))
}
