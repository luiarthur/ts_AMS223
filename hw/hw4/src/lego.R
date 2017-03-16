bd <- function(m) {
  n <- length(m)

  cols <- sapply(m,ncol)
  rows <- sapply(m,nrow)

  stopifnot(all(cols == rows))

  M <- matrix(0, sum(rows), sum(cols))
  cs <- cumsum(cols)

  M[1:cs[1],1:cs[1]] <- m[[1]]
  for (i in 2:n) {
    prev <- cs[i-1]
    curr <- cs[i]
    M[(prev+1):curr,(prev+1):curr] <- m[[i]]
  }

  return(M)
}
# bd(list(matrix(1,2,2),matrix(3,2,2),matrix(1,1,1),matrix(2,3,3)))

Jw <- function(x) matrix(c(cos(x),sin(x),-sin(x),cos(x)),2,2,byrow=TRUE)
J <- function(n) {
  M <- diag(n)
  if (n>1) for (i in 1:(n-1)) M[i,i+1] <- 1
  M
}

E <- function(p) c(1,rep(0,p-1))
