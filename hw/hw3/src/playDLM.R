library(dlm)

set.seed(1)

k <- 3; p <- 12; nAhead <- 12*12

m <- dlmModPoly(k) + dlmModSeas(p); m0(m) <- rnorm(p+k-1,sd=1); f <- dlmForecast(m,nAhead=nAhead); plot(f$f,type='l')

while(diff(range(f$f)) > 20) {
  m <- dlmModPoly(k) + dlmModSeas(p); m0(m) <- rnorm(p+k-1,sd=1); f <- dlmForecast(m,nAhead=nAhead); plot(f$f,type='l')
}

#k <- 3; p <- 12;  m <- dlmModPoly(k) + dlmModSeas(p); 
#m0(m) <-  c(0.144172582,  0.544237163, -0.008997651,  0.689190381,  0.605562177,
#            -1.251772252,  1.286033342,  0.550264557,  1.590749334, -0.658264140,
#            -0.910128602,  0.069689809, -0.237961815, -0.303046914)
#f <- dlmForecast(m,nAhead=100); plot(f$f,type='l')
