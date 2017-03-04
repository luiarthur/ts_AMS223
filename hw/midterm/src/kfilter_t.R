kfilter_t <- function(y,m0=0,C0=1,n0=1,d0=1,delta=.9) {
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

  list(y=y, delta=delta, param=param, prior=prior)
}


ll_pred_density_t <- function(filt) {
  y <- filt$y
  N <- length(y)
  f <- sapply(filt$param, function(x) x$f)
  Q <- sapply(filt$param, function(x) x$Q)
  n <- sapply(filt$param, function(x) x$n)
  T01 <- (y - f) / sqrt(Q)

  sum(dt(T01, df=n-1, log=TRUE))
}
