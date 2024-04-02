#' @title qqnormGpu
#' @description Calculate quantiles on GPU and produce a Q-Q plot in R
#' @param y Data sample
#' @param ylim  Limits on the plot region
#' @param mu  Mean of Normal distribution, default is 0
#' @param sigma  Variance of Normal distribution, default is 1
#' @param lower.tail Logical, whether use lower tail probability, default is TRUE
#' @param main plot label
#' @param xlab plot label
#' @param ylab plot label
#' @param Nglobal Size of the index space for use, default is 64 by 4
#' @param Nlocal Work group size of the index space
#' @param verbose if TRUE, print extra information
#' @param ... other graphical parameters
#' @return the Normal Q-Q plot
#' @examples 
#' library(clrng)
#' y <- stats::rt(256, df = 5)  # generates 256 random numbers from a Student's t-distribution
#' clrng::qqnormGpu(y, ylim=c(-4,5), mu=0, sigma=1, Nglobal=c(16,4))
#' x<-stats::rnorm(256)
#' clrng::qqnormGpu(x, Nglobal=c(8,6))
#' 
#' @useDynLib clrng
#' @export

qqnormGpu<-function(y, ylim, mu=0, sigma=1, lower.tail=1,
                  main = "Normal Q-Q Plot",
                  xlab = "Theoretical Quantiles", ylab = "Sample Quantiles",
                  Nglobal = getOption('clrng.Nglobal'), 
                  Nlocal = c(2, 2),
                  verbose=FALSE, ...){
   
   if(has.na <- any(ina <- is.na(y))) { ## keep NA's in proper places
      yN <- y
      y <- y[!ina]
    }
    if(0 == (n <- length(y)))
      stop("y is empty or has only NAs")
    
    if (missing(ylim))
      ylim <- range(y)
    
    if(sigma<0){
      stop("sigma must not be less than 0")
    }
    
    if(sigma==0){
      x<- rep(mu, n)
    }
    
    if (is.null(Nglobal)) stop("Nglobal is missing")
    
    if(verbose) {
      cat('local sizes ', toString(Nlocal), '\nglobal sizes ', toString(Nglobal), '\n')
    }
    

 #   p <-gpuR::vclVector(ppoints(n), type=gpuR::typeof(y))
    out <-gpuR::vclVector(length=as.integer(n), type=gpuR::typeof(y))
   
    x <- as.vector(cpp_gpu_qqnorm(out, mu,sigma, lower.tail, Nglobal , Nlocal))
    
    x <- x[order(order(as.vector(y)))]  ###
    
    
    if(has.na) {
      y <- x; 
      x <- yN; 
      x[!ina] <- y;
      y <- yN
    }
    
    
      plot(x, y, main = main, xlab = xlab, ylab = ylab, ylim = ylim, ...)
   
      invisible(list(x = x, y = y))
       
      
  }



































