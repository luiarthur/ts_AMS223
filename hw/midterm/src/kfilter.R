kfilter <- function(y,m0=0,C0=1,n0=1,d0=1,delta=.9) {
  N <- length(y)

  m <- double(N)
  C <- double(N)
  n <- double(N)
  d <- double(N)

  m[1] <- m0
  C[1] <- C0
  n[1] <- n0
  d[1] <- d0

  update_R <- function(C_prev,W_curr) {
    C_prev + W_curr
  }

  update_Q <- function(R_curr) R_curr + 1

  update_m <- function(m_prev, R_curr, Q_curr, y_curr) {
    m_prev - R_curr/Q_curr * (y_curr-m_prev)
  }

  update_C <- function(R_curr,Q_curr) R_curr - R_curr^2 / Q_curr
  update_W <- function(C_prev) C_prev * (1-delta)/delta

  update_n <- function(n_prev) n_curr + 1
  update_d <- function(d_prev,y_curr,m_prev,Q_curr) {
    d_curr + (y_curr-m_prev)^2 / Q_curr
  }

  for (i in 2:N) {
    W <- update_W(C[i-1])
    R <- update_R(C[i-1],W)
    Q <- update_Q(R)

    m[i] <- update_m(m[i-1], R, Q, y[i])
    C[i] <- update_C(R,Q)
    n[i] <- update_n(n[i-1])
    d[i] <- update_d(d[i-1], y[i], m[i-1], Q)
  }

  list(m=m, C=C, n=n, d=d, y=y)
}

forecast <- function(filt,nAhead) {
  N <- length(filt$y)
}
