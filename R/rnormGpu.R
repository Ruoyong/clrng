#' @title rnormGpu
#' @description Generate standard normal random numbers on a GPU
#' @param n A number or a vector specifying the size of output vector or matrix
#' @param streams Streams object. 
#' @param Nglobal NDRange of work items for use
#' @param type Precision type of random numbers, "double" or "float"
#' @param verbose if TRUE, print extra information 
#' @import gpuR
#' @return A 'vclVector' or 'vclMatrix' of standard normal random numbers
#' @examples 
#' library(clrng)
#' streams <- createStreamsGpu(8)
#' as.vector(rnormGpu(7, streams=streams, Nglobal=c(4,2)))
#' as.matrix(rnormGpu(c(2,3), streams=streams, Nglobal=c(4,2), type="float"))
#' 
#' @useDynLib clrng
#' @export




rnormGpu = function(
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
    stop("streams must be supplied")
  }
    if(missing(Nglobal)){
    stop("Nglobal required")
    }
  
    # if(missing(streams)) {
    #    initial = as.integer(rep(12345,6))
    #    streams<-vclMatrix(0L, nrow=prod(Nglobal), ncol=12, type="integer")
    #    CreateStreamsGpuBackend(initial, streams, keepInitial=1)
    #    currentCreator <- streams[nrow(streams),]
    #    assign(".Random.seed.clrng",  currentCreator, envir = .GlobalEnv)
    #  }
     
    if(prod(Nglobal) > nrow(streams)){
       warning("the number of streams created should always equal (or exceed)
the maximum number of work items likely to be used")
    }
  
  
    gpuRnBackend(xVcl, streams, Nglobal,"normal", verbose) 
  
  #  invisible(streams)
  
  if( nrow(xVcl)==1 & is.numeric(n)) xVcl = xVcl[1,]
  
  xVcl
  
}






