library(msm) # rtnorm (truncated normal)
library(dlm)
source('Gibbs.R')

ffbs <- function(y, q=2, B=2000, burn=1000, printFreq=100, 
                 # prior for static parameters
                 aw=2,bw=10,av=2,bv=10,
                 # prior for state parameters
                 m0=rep(0,q),C0=diag(1,q),n0=1,d0=1,tau=30,
                 phi.lower=-1,phi.upper=1) {

  N <- length(y)
  x <- 1:N
  FF <- matrix(c(1, rep(0,q-1)))
  Iq <- diag(q)
  W <- tau*Iq 


  # Update DLM state params
  update.state <- function(param) {
    ### Forward Filtering
    #F.mat <- matrix(c(FF), nrow=N, ncol=q, byrow=TRUE)
    #mod <- dlmModReg(F.mat,addInt=FALSE, dV=param$v, dW=diag(W), m0=m0, C0=C0)
    mod <- dlmModPoly(q, dV=param$v, dW=diag(W), m0=m0, C0=C0)
    GG(mod) <-  rbind(param$phi, cbind(diag(q-1),0))
    level <- param$alpha + x*param$beta
    filt <- dlmFilter(y-level, mod=mod)
    ### Backward Sampling
    param$theta <- dlmBSample(filt)

    return(param)
  }

  # Update static params (alpha, beta, w, phi, v)
  update.static <- function(param){
    theta <- param$theta[-1,]
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
    theta.prev <- theta[-(N+1),]
    phi <- param$phi
    for (j in 1:q) {
      #phi[j] <- rtnorm(1, 
      #                 sum(phi[-j])*sum(theta.prev[,j])/(tau*sum(theta.prev[,j]^2)),
      #                 sqrt(1/(tau*sum(theta.prev[,j]^2))), phi.lower, phi.upper)
      phi[j] <- rnorm(1, 
                       sum(phi[-j])*sum(theta.prev[,j])/(tau*sum(theta.prev[,j]^2)),
                       sqrt(1/(tau*sum(theta.prev[,j]^2))))

    }
    param$phi <- phi

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

  list(samps=samps, dat=y)
}
