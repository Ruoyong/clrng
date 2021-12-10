#' @title rnorm
#' @description Generate standard normal random numbers on a GPU
#' @param n A number or a vector specifying the size of output vector or matrix
#' @param streams Streams object
#' @param Nglobal NDRange of work items for use
#' @param type Precision type of random numbers, "double" or "float"
#' @param verbose if TRUE, print extra information 
#' @return A 'vclVector' or 'vclMatrix' of standard normal random numbers
#' @examples 
#' library(clrng)
#' as.vector(rnorm(7, Nglobal=c(4,2)))
#' as.matrix(rnorm(c(2,3), Nglobal=c(2,2), type="float"))
#' streams <- createStreamsGpu(8, initial = rep(26,6))
#' as.vector(rnorm(3, streams=streams, Nglobal=c(4,2)))
#' @useDynLib clrng
#' @export




rnorm = function(
  n, 
  streams, 
  Nglobal,
  type=c("float", "double")[1+gpuInfo()$double_support],
  verbose = FALSE) {
  
  if(any(grepl("vclMatrix", class(n)))) {
    xVcl = n
  } else {
    if(length(n)>=3){
      stop("'n' has to be a vector of no more than two elements")
    }
    if(length(n)==0){
      stop("specify the number of rows and columns of the output matrix")
    }
    if(length(n)==1){
      n<-c(1,n)
    }
    xVcl<-gpuR::vclMatrix(0, nrow=n[1], ncol=n[2], type=type[1])
  }
  
  if(Nglobal[2]<2){
    stop("number of work items needs to be an even number for second dimension\n")
  }
  
  if(missing(streams)) {
    if(missing(Nglobal)) {
      Nglobal = c(64,8)
      seedR = sample.int(2147483647, 6, replace = TRUE) 
      seed <- gpuR::vclVector(seedR, type="integer")  
      streams<-vclMatrix(0L, nrow=512, ncol=12, type="integer")
      CreateStreamsGpuBackend(seed, streams, keepInitial=1)
    }else{
      seedR = sample.int(2147483647, 6, replace = TRUE)
      seed <- gpuR::vclVector(seedR, type="integer")  
      streams<-vclMatrix(0L, nrow=prod(Nglobal), ncol=12, type="integer")
      CreateStreamsGpuBackend(seed, streams, keepInitial=1)
    }
  }else if(missing(Nglobal)){
    stop("number of work items needs to be same as number of streams")
  }else if(prod(Nglobal) != nrow(streams)){
    warning("number of work items needs to be same as number of streams")
  }
  
  
  
  gpuRnBackend(xVcl, streams, Nglobal,"normal", verbose) 
  
  #  invisible(streams)
  
  if( nrow(xVcl)==1 & is.numeric(n)) xVcl = xVcl[1,]
  
  xVcl
  
}






