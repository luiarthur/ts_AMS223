gibbs <- function(init, update, B=2000, burn=100, printFreq=0) {

  out <- as.list(1:B)
  out[[1]] <- init

  for (i in 2:(B+burn)) {
    out[[i]] <- update(out[[i-1]])
    if (printFreq > 0 && i%%printFreq==0) cat("\rProgress: ",i,"/",B+burn)
  }

  tail(out,B)
}

rig <- function(shp,rate) 1 / rgamma(1,shp,rate)
