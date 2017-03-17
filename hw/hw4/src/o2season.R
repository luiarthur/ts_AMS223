# o2season.R
# Order-2 (linear trend) seasonal components (any harmonics)
source("lego.R")

gen.default.prior <- function(num.harmonics) {
  # do this sometime?
}

# get trend block
tb  <- function(M) M[1:2,1:2]

# get seasonal block
sb <- function(M) M[-c(1:2),-c(1:2)]

# Check if vector is ascending
ascending <- function(x) {
  n <- length(x)
  x0 <- c(-Inf, x[1:n-1])
  all(x > x0)
}

# delta = c(delta_trend, delta_season)
# if num.harmonics == p/2 and p is even, 
# then ignore the Nyquist, that is
# the state vector has only (p-1)/2 frequencies if p is even
# with the G matrix being a (p-1)/2 + 1 dimensional, the
# last diag being -1. Refer to W&H.
o2season <- function(y,harmonics,period,delta=c(.95,.95),
                     m0=rep(0,length(harmonics)*2+2),
                     C0=diag(length(harmonics)*2+2),n0=1,d0=1) {

  num.harmonics <- length(harmonics)
  nyquist <- floor(period / 2)
  has.nyquist <- (nyquist %in% harmonics) && (period%%2==0)

  stopifnot(ascending(harmonics))
  stopifnot(max(harmonics) <= nyquist)

  N <- length(y)
  FF <- matrix( rep(E(2),num.harmonics+1) )
  DF <- (1-delta) / delta
  w <- 2*pi / period
  Jws <- lapply(as.list(harmonics), function(h) Jw(h*w))
  G1 <- J(2)
  G2 <- bd(Jws)

  if (has.nyquist && period%%2==0) {
    FF <- as.matrix(FF[-nrow(FF),])
    G2 <- as.matrix(G2[-nrow(G2), -ncol(G2)])

    m0 <- m0[1:length(FF)]
    C0 <- as.matrix(C0[1:length(FF), 1:length(FF)])
  }

  G <- bd(list(G1,G2))

  param <- as.list(1:N)
  prior <- list(m=m0, C=C0, n=n0, S=d0/n0)

  for (i in 1:N) {
    prev <- if (i>1) param[[i-1]] else prior

    W1 <- DF[1] * G1 %*% tb(prev$C) %*% t(G1)
    W2 <- DF[2] * G2 %*% sb(prev$C) %*% t(G2)
    W <- bd(list(W1,W2))
    n <- prev$n + 1
    R <- G %*% prev$C %*% t(G)+ W
    Q <- c(t(FF) %*% R %*% FF + prev$S)
    a <- G %*% prev$m
    f <- c(t(FF) %*% a)
    A <- R %*% FF / Q
    e <- y[i] - f
    m <- a + A*e
    S <- prev$S + prev$S/n * (e^2/Q - 1)
    C <- S/prev$S * (R-A%*%t(A) * Q)

    param[[i]] <- list(m=m,C=C,n=n,Q=Q,R=R,f=f,S=S)
  }

  list(y=y,delta=delta,FF=FF,prior,G=G,param=param,prior=prior)
}

smoothing <- function(filt) {
  m <- lapply(filt$param, function(p) p$m)
  S <- sapply(filt$param, function(p) p$S)
  C <- lapply(filt$param, function(p) p$C)
  R <- lapply(filt$param, function(p) p$R)
  G <- filt$G

  #B <- function(j) ifelse(j>0, C[[j]], filt$prior$C) %*% t(G) %*% solve(R[[j+1]])
  B <- function(j) (if(j>0) C[[j]] else filt$prior$C) %*% t(G) %*% solve(R[[j+1]])

  a <- function(t,minus_k) {
    k <- -minus_k
    if (k==0) m[[t]] else m[[t-k]] + B(t-k) %*% (a(t,-k+1) - m[[t-k]])
  }

  Rt <- function(t,minus_k) {
    k <- -minus_k
    if (k==0) C[[t]] else {
      BB <- B(t-k)
      C[[t-k]] + BB %*% (Rt(t,-k+1) - R[[t-k+1]]) %*% t(BB)
    }
  }

  N <- length(filt$y)
  aa <- lapply((N-1):0, function(i) a(N,-i))
  VV <- lapply((N-1):0, function(i) (S[N]/S[N-i]) * Rt(N,-i))

  list(a=aa, V=VV)
}


forecast <- function(filt, nAhead=1) {
  delta <- filt$delta
  DF <- (1-delta) / delta
  FF <- filt$F
  G <- filt$G

  N <- length(filt$y)
  plast <- filt$param[[N]]

  S <- plast$S
  a <- plast$m
  R <- plast$C

  W <- function(Rprev) {
    W1 <- DF[1] * tb(G) %*% tb(Rprev) %*% t(tb(G))
    W2 <- DF[2] * sb(G) %*% sb(Rprev) %*% t(sb(G))
    bd( list(W1,W2) )
  }

  f <- rep(NA, nAhead)
  Q <- rep(NA, nAhead)

  for(i in 1:nAhead) {
    a <- G%*%a
    R <- G %*% R %*% t(G) + W(R)
    f[i] <- t(FF) %*% a
    Q[i] <- t(FF) %*% R %*% FF + S
  }


  list(f=f, Q=Q, n=plast$n)
}
