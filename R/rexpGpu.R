#' @title rexpGpu
#' @description Generate exponential random numbers parallely on a GPU
#' @param n A number or a vector specifying the size of the output vector or matrix
#' @param rate Distribution parameter, mean equals to 1/rate
#' @param streams a vclMatrix of streams. 
#' @param Nglobal NDRange of work items for use, with default value from global option 'clrng.Nglobal'
#' @param type "double" or "float" of generated random numbers, with default value from global option 'clrng.type'
#' @param verbose if TRUE, print extra information, default value is FALSE
#' @import gpuR
#' 
#' @details \code{type} specifies the precision type of random numbers. If GPU supports "double", 'clrng.Nglobal' is "double", otherwise, `clrng.Nglobal' is "single"
#' 
#' @return a 'vclVector' or 'vclMatrix' of exponential random numbers
#' 
#' @examples
#' library('clrng')
#' setContext(grep("gpu", listContexts()$device_type)[1])
#' streams <- createStreamsGpu()
#' as.vector(rexpGpu(7, streams=streams))
#' 
#' # to produce float precision random numbers
#' options(clrng.type='float')
#' as.matrix(rexpGpu(c(2,3), rate=0.5, streams))
#' 
#' @useDynLib clrng
#' @export


rexpGpu = function(
  n, 
  rate=1,
  streams, 
  Nglobal = getOption('clrng.Nglobal'),
  type = getOption('clrng.type'),
  verbose = FALSE) {

  if (is.null(Nglobal)) stop("Nglobal is missing")
  if (is.null(type))    stop('precision type missing')
  
  if(length(n)>=3){
    stop("'n' has to be a vector of no more than two elements")
  }
  if(length(n)==0){
    stop("need to specify the number of rows and columns of the output matrix")
  }
  if(length(n)==1){
    n<-c(n,1)
  }
  
  if(Nglobal[2]%%2 !=0 ){
    stop("number of work items in dimension 2 must be a multiple of 2")
  }
  
  if(rate <= 0 || !is.finite(rate)){
    stop("invalid rate value")
  }
  
  # if(Nglobal[2]<2){
  #   stop("number of work items needs to be an even number for second dimension\n")
  # }
  
  
    if(missing(streams)) {
       stop("streams must be supplied")
    }
  
   # if(missing(streams)) {
   #    initial = as.integer(rep(12345,6))
   #    streams<-vclMatrix(0L, nrow=prod(Nglobal), ncol=12, type="integer")
   #    CreateStreamsGpuBackend(initial, streams, keepInitial=1)
   #    currentCreator <- streams[nrow(streams),]
   #    assign(".Random.seed.clrng",  currentCreator, envir = .GlobalEnv)
   #  }
  
    if(prod(Nglobal) > nrow(streams)){
      warning("the number of streams created should always equal (or exceed) the maximum number of work items likely to be used")
    }
  
  
  
  
  xVcl<-gpuR::vclMatrix(0, nrow=n[1], ncol=n[2], type=type[1])     
  
  
  gpuRnBackend(xVcl,streams, Nglobal,"exponential", FALSE) 
  
  invisible(streams)
  
  if(ncol(xVcl)==1) xVcl = xVcl[,1]
  
  (1/rate) * xVcl
  
}

