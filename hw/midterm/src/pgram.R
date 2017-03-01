my.pgram <- function(y) {
  n <- length(y)
  tt <- 1:n

  k <- 1:floor(n/2 - .5)
  omega <- 2*pi*k/n
  lam <- 2*pi / omega

  a.hat <- (2/n)*sapply(omega, function(w) sum(y * cos(w * tt)))
  b.hat <- (2/n)*sapply(omega, function(w) sum(y * sin(w * tt)))
  Iw <- (n/2)*(a.hat^2 + b.hat^2)
  log_post <- (1 - n/2) * log(1 - Iw/sum(y^2))

  list(omega=omega,lam=lam,log_post=log_post,Iw=Iw)
}
