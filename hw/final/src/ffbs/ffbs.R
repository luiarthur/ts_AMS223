library(msm) # rtnorm (truncated normal)
library(dlm)
source('Gibbs.R')

ffbs <- function(y, q=2, B=2000, burn=1000, printFreq=100, 
                 # prior for static parameters
                 aw=2,bw=1,
                 av=1/2,bv=1/2, # same as n0/2, d0/2
                 # prior for state parameters
                 m0=rep(0,q),C0=diag(1,q),tau=30,
                 phi.lower=-1,phi.upper=1) {

  N <- length(y)
  x <- 1:N
  FF <- matrix(c(1, rep(0,q-1)))
  G <- function(phi,q=length(phi)) if (q>1) rbind(phi, cbind(diag(q-1),0)) else phi
  Iq <- diag(q)
  W <- tau*Iq 


  # Update DLM state params
  update.state <- function(param) {
    ### Forward Filtering
    mod <- dlm(m0=m0, C0=C0, FF=t(FF), V=param$v, GG=G(param$phi), W=W)
    level <- param$alpha + x*param$beta
    filt <- dlmFilter(y-level, mod=mod)
    ### Backward Sampling
    param$theta <- dlmBSample(filt)

    return(param)
  }

  # Update static params (alpha, beta, w, phi, v)
  update.static <- function(param){
    theta <- param$theta[-1,]
    theta.prev <- param$theta[-(N+1),]
    theta1 <- if (NCOL(theta)>1) theta[,1] else theta
    Ftheta <- theta %*% FF # theta is (N x q)

    ### alpha
    z1 <- sum(y - x*param$beta - Ftheta)
    param$alpha <- rnorm(1, (param$w*z1)/(1+param$w*N), 
                         sqrt(param$w*param$v/(1+param$w*N)))

    ### beta
    z2 <- t(y - param$alpha - Ftheta) %*% x
    xx <- sum(x^2)
    param$beta <- rnorm(1, param$w*z2/(param$w*xx+1), 
                        sqrt(param$v*param$w/(param$w*xx+1)))

    ### w
    param$w <- rig(aw + 1, bw + (param$alpha^2+param$beta^2)/(2*param$v))

    ### phi
    phi.XXi <- solve( t(theta.prev) %*% theta.prev )
    phi.mu <- phi.XXi %*% t(theta.prev)%*% theta1
    param$phi <- c(mvrnorm(phi.mu, tau*phi.XXi))

    ### v
    param$v <- rig(av+N/2, bv+sum((y-param$alpha-x*param$beta-Ftheta)^2)/2)

    return(param)
  }

  # Update function for Gibbs
  update.all <- function(param) {
    param <- update.static(param)
    param <- update.state(param)
    return(param)
  }

  init <- NULL
  init$alpha <- 0
  init$beta <- 0
  init$v <- 1
  init$w <- 1
  init$phi <- rep(0,q)
  init$theta <- matrix(rnorm((N+1)*q),N+1,q)

  samps <- gibbs(init, update.all, B, burn, printFreq)

  list(samps=samps, dat=y, tau=tau, q=q, FF=FF)
}

to.arr <- function(ls_mat) {
  N <- length(ls_mat)
  mat.dim <- dim(ls_mat[[1]])
  out <- array(NA, dim=c(mat.dim[1],mat.dim[2],N))
  for (i in 1:N) out[,,i] <- ls_mat[[i]]
  return(out)
}


forecast <- function(ffbs.out, nAhead=1, ci.level=.9) {
  N <- length(ffbs.out$dat)
  q <- ncol(ffbs.out$samp[[1]]$theta)
  B <- length(ffbs.out$samps)
  W <- diag(q) * ffbs.out$tau

  FF <- matrix(c(1, rep(0,q-1)))
  G <- function(phi,q=length(phi)) if (q>1) rbind(phi, cbind(diag(q-1),0)) else phi

  theta <- to.arr(lapply(ffbs.out$samps, function(s) s$theta))
  phi <- t(sapply(ffbs.out$samps, function(s) s$phi)) #(Bxq)

  theta <- to.arr(lapply(ffbs.out$samps, function(s) s$theta))
  theta.last <- theta[N+1,,] # (qxB)

  alpha <- sapply(ffbs.out$samps, function(s) s$alpha)
  beta <- sapply(ffbs.out$samps, function(s) s$beta)
  v <- sapply(ffbs.out$samps, function(s) s$v)

  f <- matrix(NA,nAhead,B)
  for(i in 1:nAhead) {
    a <- sapply(1:B, function(b) 
                mvrnorm(0,W) + G(phi[b,]) %*% if (i==1) theta.last[,b] else a[,b])

    f[i,] <- sapply(1:B, function(b) 
                    alpha[b] + beta[b]*(N+i) + t(FF) %*% a[,b]) + rnorm(B,0,sqrt(v))
  }

  return(f)
}

G.roots <- function(ffbs.out) { # if all roots are complex
  N <- length(ffbs.out$dat)
  q <- ncol(ffbs.out$samp[[1]]$theta)
  B <- length(ffbs.out$samps)

  G <- function(phi,q=length(phi)) if (q>1) rbind(phi, cbind(diag(q-1),0)) else phi
  phi <- lapply(ffbs.out$samps, function(s) s$phi)

  # eigen values are reciprocal roots of characteristic polynomial when the
  # eigen values are distinct
  Groot <- lapply(phi, function(p) eigen(G(p))$values + 1E-10i)
  mod <- sapply(Groot, function(r) Mod(r)) # REQUIRES pairs of complex roots!
  arg <- sapply(Groot, function(r) Arg(r)) # REQUIRES pairs of complex roots!

  list(mod=mod, arg=arg)
}
