#' @title qqnorm
#' @description Calculate quantiles on GPU and produce a Q-Q plot in R
#' @param y Data sample
#' @param ylim  Limits on the plot region
#' @param mu  Mean of Normal distribution, default is 0
#' @param sigma  Variance of Normal distribution, default is 1
#' @param lowertail Logical, whether use lower tail probability, default is TRUE
#' @param main plot label
#' @param xlab plot label
#' @param ylab plot label
#' @param Nglobal Size of the index space for use, default is 64 by 4
#' @param Nlocal Work group size of the index space
#' @param verbose if TRUE, print extra information
#' @return the Normal Q-Q plot
#' @useDynLib clrng
#' @export

qqnorm<-function(y, ylim, mu=0, sigma=1, lowertail=1,
                  main = "Normal Q-Q Plot",
                  xlab = "Theoretical Quantiles", ylab = "Sample Quantiles",
                  Nglobal, Nlocal = c(2, 2),
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

    if(missing(Nglobal)) 
    {Nglobal = c(64,4)}
    
    
    if(verbose) {
      cat('local sizes ', toString(Nlocal), '\nglobal sizes ', toString(Nglobal), '\n')
    }
    

 #   p <-gpuR::vclVector(ppoints(n), type=gpuR::typeof(y))
    out <-gpuR::vclVector(length=as.integer(n), type=gpuR::typeof(y))
   
    x <- as.vector(cpp_gpu_qqnorm(out, mu,sigma, lowertail, Nglobal , Nlocal))
    
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



































