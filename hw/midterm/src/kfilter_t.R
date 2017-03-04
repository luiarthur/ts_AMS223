last <- function(x) x[length(x)]

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

  sum(dt(T01, df=n-1, log=TRUE)-log(Q)/2) 
}

smoothing <- function(filt) {
  m <- sapply(filt$param, function(p) p$m)
  S <- sapply(filt$param, function(p) p$S)
  C <- sapply(filt$param, function(p) p$C)
  Rvec <- sapply(filt$param, function(p) p$R)

  B <- function(j) ifelse(j>0,C[j],filt$prior$m) / R[j+1]

  a <- function(t,minus_k) {
    k <- -minus_k
    if (t-k==0) m[t] else m[t-k] + B(t-k) * (a(t,-k+1) - m[t-k])
  }

  R <- function(t,minus_k) {
    k <- -minus_k
    if (t-k==0) C[t] else C[t-k] - B(t-k)^2 * (Rvec[t-k+1] - R(t,-k+1))
  }

  N <- length(filt$y)
  aa <- sapply(1:N, function(i) a(N,-i))
  VV <- sapply(1:N, function(i) R(N,-i))


  list(a=aa, V=VV)
}
