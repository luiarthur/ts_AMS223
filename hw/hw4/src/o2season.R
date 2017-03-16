# o2season.R
# Order-2 (linear trend) seasonal components (any harmonics)
source("lego.R")

gen.default.prior <- function(num.harmonics) {
  # do this sometime?
}

# delta = c(delta_trend, delta_season)
o2season <- function(y,harmonics,period,delta=c(.95,.95),
                     m0=rep(0,length(harmonics)*2+2),
                     C0=diag(length(harmonics)*2+2),n0=1,d0=1) {
  num.harmonics <- length(harmonics)

  N <- length(y)
  param <- as.list(1:N)

  prior <- list(m=m0, C=C0, n=n0, S=d0/n0)

  # get trend block
  tb  <- function(M) M[1:2,1:2]

  # get seasonal block
  sb <- function(M) M[-c(1:2),-c(1:2)]

  FF <- matrix(c(E(2), rep(E(2),num.harmonics)))
  w <- 2*pi / period
  Js <- lapply(as.list(harmonics), function(h) Jw(h*w))

  G1 <- J(2)
  G2 <- bd(Js)
  G <- bd(list(G1,G2))

  DF <- (1-delta) / delta

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

  list(y=y, delta=delta, FF=FF, prior, G=G, param=param)
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
  N <- length(filt$y)
  C <- lapply(filt$param, function(p) p$C)
  m <- lapply(filt$param, function(p) p$m)
  delta <- filt$delta
  FF <- filt$F
  G <- filt$G

  plast <- filt$param[[N]]

  #f <- rep(plast$m,nAhead)

  W_star <- rep(NA,nAhead)
  R <- plast$R
  Q <- plast$Q
  DF <- (1-delta) / delta
  for (i in 1:nAhead) {
    W_star[i] <- DF * R/Q
    R <- R/Q + W_star[i]
    Q <- R + 1
  }

  W <- plast$S * W_star

  Q <- plast$C + cumsum(W) + plast$S # + p.57 W&H # FIXME

  aT <- function(k) if (k==0) m[N] else aT(k-1)
  fT <- function(t,k) if (k==0) t(FF) %*% aT(k)
  RT <- function(k) if (k==0) C[N] else RT(k-1) + W[k]

  aa <- sapply(1:12, aT)
  RR <- sapply(1:12, RT)

  list(f=f, Q=Q, n=filt$param[[N]]$n, a=aa, R=RR)
}
