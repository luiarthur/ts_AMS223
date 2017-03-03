kfilter <- function(y,m0=0,C0=1,n0=1,d0=1,delta=.9) {
  N <- length(y)


  param <- as.list(1:N)


  update_R <- function(C_prev,W_curr) C_prev + W_curr
  update_Q <- function(R_curr) R_curr + 1
  update_W <- function(C_prev) C_prev * (1-delta)/delta

  update_m <- function(m_prev, R_curr, Q_curr, y_curr) {
    m_prev + (R_curr/Q_curr) * (y_curr-m_prev)
  }
  update_C <- function(R_curr,Q_curr) {
    R_curr - R_curr^2 / Q_curr
  }
  update_n <- function(n_prev) {
    n_prev + 1
  }
  update_d <- function(d_prev,y_curr,m_prev,Q_curr) {
    d_prev + (y_curr-m_prev)^2 / Q_curr
  }

  W1 <- update_W(C0)
  R1 <- update_R(C0,W1)
  Q1 <- update_Q(R1)
  param[[1]] <- list(m=m0, C=C0, n=n0, d=d0, Q=Q1, R=R1)
  for (i in 2:N) {
    prev <- param[[i-1]]

    W <- update_W(prev$C)
    R <- update_R(prev$C,W)
    Q <- update_Q(R)

    m <- update_m(prev$m, R, Q, y[i])
    C <- update_C(R,Q)
    n <- update_n(prev$n)
    d <- update_d(prev$d, y[i], prev$m, Q)

    param[[i]] <- list(m=m,C=C,n=n,d=d,Q=Q,R=R)
  }

  list(y=y, delta=delta, param=param)
}

kfilter.theta <- function(filt,B=1000) {

  samp <- function(param) {
    oneSamp <- function(dummy) {
      v <- 1 / rgamma(1, param$n/2, rate=param$d/2)
      rnorm(1, param$m, sqrt(v*param$C))
    }

    sapply(1:B, oneSamp)
  }

  sapply(filt$param, samp)
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
