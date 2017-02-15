sample_w <- function(y, B=1000, lp_w=function(w) dunif(w,min=0,max=pi), scale=1) {
  pgram_y <- spec.pgram(y, plot=FALSE)
  w <- pgram_y$freq * scale
  Iw <- pgram_y$spec
  yy <- sum(y^2)
  N <- length(y)
  ll_plus_lp <- (1-N/2) * log(1-Iw/yy) + lp_w(w)

  p <- exp(ll_plus_lp - max(ll_plus_lp))

  sample(w, B, replace=TRUE, p)
}
