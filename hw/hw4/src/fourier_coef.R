is.even <- function(x) x %% 2 == 0

# y_j = a_0 + \sum_{r=0}^h a_r cos(alpha rj) + b_r sin(alpha rj) 
fourier_coef <- function(y, p=length(y)) {
  h <- floor(p/2)
  alpha <- 2*pi / p

  j <- 0:(p-1)
  
  a_r <- sapply(1:(h-1), function(r) 2/p * sum(y*cos(alpha*r*j)) )
  b_r <- sapply(1:(h-1), function(r) 2/p * sum(y*sin(alpha*r*j)) )
  a_0 <- mean(y)
  a_h <- mean((-1)^j*y)
  b_h <- 0

  a <- c(a_r,a_h)
  b <- c(b_r,b_h)

  A <- sqrt(a^2 + b^2) # Amplitude
  phase <- atan(-b/a)

  r <- 1:h

  # Total variation about mean a_0
  total.variation <- if (is.even(p)) 
    sum(A^2) * p/2 
  else 
    (p/2)*sum(A[1:(h-1)]^2) + p*A[h]^2

  list(a_0=a_0, a=a, b=b, A=A, phase=phase, total.variation=total.variation)
}

fourier_trans <- function(coef,n=0) {
  p <- length(coef$a) * 2
  n <- ifelse(n==0,p,n)
  j <- 0:(n-1)
  alpha <- 2*pi / p
  h <- floor(p/2)
  r <- 1:h
  coef$a_0 + sapply(j, function(i) sum(coef$a*cos(alpha*r*i) + coef$b*sin(alpha*r*i)))
}
