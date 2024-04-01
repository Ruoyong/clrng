#' @title rnormGpu
#' @description Generate standard normal random numbers parallely on a GPU
#' @param n a number or a vector specifying the size of output vector or matrix
#' @param streams a vclMatrix of streams. 
#' @param Nglobal a (non-empty) integer vector specifying size of work items for use
#' @param type a character string specifying "double" or "float" of random numbers, default depends on GPU capabilities
#' @param verbose a logical value, if TRUE, print extra information. Default is set to FALSE
#' @import gpuR
#' @return a 'vclVector' or 'vclMatrix' of standard normal random numbers
#' @examples 
#' library(clrng)
#' streams <- createStreamsGpu(8)
#' as.vector(rnormGpu(7, streams=streams, Nglobal=c(4,2)))
#'
#' #Change global options
#’ options(type="float") 
#' as.matrix(rnormGpu(c(2,3), streams=streams, Nglobal=c(4,2)))
#' 
#' @useDynLib clrng
#' @export



rnormGpu = function(
  n, 
  streams, 
  Nglobal,
  type=getOption('type', default = c('float','double')[1+gpuR::gpuInfo()$double_support]),
  verbose=getOption("verbose", default = FALSE)) {
  
  
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






