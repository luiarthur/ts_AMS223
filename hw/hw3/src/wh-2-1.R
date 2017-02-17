library(dlm)

source("sim_dlm.R")

y <- sim_1_dlm(100,W=.05); plot(ts(y), ylim=c(10,40))
y <- sim_1_dlm(100,W=.005); plot(ts(y), ylim=c(10,40))
