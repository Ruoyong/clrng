#' @title rnormGpu
#' @description Generate standard Normal random numbers parallely on a GPU
#' @param n a number or a vector specifying the size of output vector or matrix
#' @param streams a vclMatrix of streams. 
#' @param Nglobal a (non-empty) integer vector specifying size of work items for use, with default value from global option 'Nglobal'
#' @param type a character string specifying "double" or "float" of random numbers, with default value from global option 'type'
#' @param verbose a logical value, if TRUE, print extra information, with default value from global option 'verbose'
#' @import gpuR
#' @return a 'vclVector' or 'vclMatrix' of standard normal random numbers
#' 
#' @details \code{type} specifies the precision type of random numbers. If GPU supports "double", default is "double", otherwise, default is "single"
#' 
#' @examples 
#' library(clrng)
#' currentPlatform()
#' streams <- createStreamsGpu(8)
#' as.vector(rnormGpu(7, streams=streams))
#'
#' getOption('Nglobal')
#' # use float precision and global size
#’ options(type="float", Nglobal = c(4,2)) 
#' as.matrix(rnormGpu(c(2,3), streams=streams))
#' 
#' @useDynLib clrng
#' @export



rnormGpu = function(
  n, 
  streams, 
  Nglobal = NULL,
  type = NULL,
  verbose = NULL) {
  
  if (is.null(Nglobal)) Nglobal <- getOption('Nglobal')
  if (is.null(type))    type <- getOption('type')
  if (is.null(verbose)) verbose <- getOption('verbose')
  
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
  
  if(Nglobal[2]%%2 !=0 ){
    stop("number of work items in dimension 2 must be a multiple of 2")
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






