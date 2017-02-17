sim_1_dlm <- function(n,f=1,g=1,V=1,W=1,mu_0=25) {
  y <- double(n)
  y[1] <- mu_0
  mu_old <- mu_0
  for (i in 2:n) {
    mu_new <- rnorm(1,mu_old,sqrt(W))
    y[i] <- rnorm(1,mu_new,sqrt(V))
    mu_old <- mu_new
  }

  return(y)
}
