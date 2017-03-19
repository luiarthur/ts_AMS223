package ffbs.mcmc

object Gibbs {

  import breeze.stats.distributions.{Gamma,Gaussian}
  import scala.util.Random.{nextGaussian=>randn, nextDouble=>randu}

  def rig(shp: Double, rate: Double) = 1.0 / (new Gamma(shp, 1.0/rate)).sample
  def tnorm(mu: Double, sig2: Double, lower: Double, upper: Double) = {

  }

  def timer[R](block: => R) = {
    val t0 = System.nanoTime()
    val result = block
    val t1 = System.nanoTime()
    println("Elapsed time: " + (t1 - t0) / 1E9 + "s")
    result
  }

  trait State { 
    def update(): State
    def sample(B:Int, burn:Int, printEvery:Int=0) = {
      def loop(S:List[State], i:Int): List[State] = {
        if (printEvery > 0 && i % printEvery == 0) 
          print("\rProgress: " + i +"/"+ (B+burn) + "\t")

        if (i < B + burn) {
          val newState = if (i <= burn) 
            List(S.head.update)
          else
            S.head.update :: S

          loop(newState, i+1)
        } else S
      }
      loop(List(this),0).asInstanceOf[List[this.type]]
    }
  }

}
