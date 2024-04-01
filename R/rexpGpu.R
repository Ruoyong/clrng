#' @title rexpGpu
#' @description Generate exponential random numbers parallely on a GPU
#' @param n A number or a vector specifying the size of the output vector or matrix
#' @param rate Distribution parameter, mean equals to 1/rate
#' @param streams a vclMatrix of streams. 
#' @param Nglobal NDRange of work items for use
#' @param type "double" or "float" of generated random numbers
#' @param verbose if TRUE, print extra information
#' @import gpuR
#' @return a 'vclVector' or 'vclMatrix' of exponential random numbers
#' 
#' @examples
#' library('clrng')
#' library('gpuR')
#' streams <- createStreamsGpu(8)
#' as.vector(rexpGpu(7, streams=streams, Nglobal=c(4,2)))
#' as.matrix(rexpGpu(c(2,3), rate=0.5, streams, Nglobal=c(4,2), type="float"))
#' 
#' @useDynLib clrng
#' @export


rexpGpu = function(
  n, 
  rate=1,
  streams, 
  Nglobal,
  type=getOption('type', default = c('float','double')[1+gpuR::gpuInfo()$double_support]),
  verbose=getOption("verbose", default = FALSE)) {

  
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
      warning("the number of streams created should always equal (or exceed) the maximum number of work items likely to be used")
    }
  
  
  
  
  xVcl<-gpuR::vclMatrix(0, nrow=n[1], ncol=n[2], type=type[1])     
  
  
  gpuRnBackend(xVcl,streams, Nglobal,"exponential", FALSE) 
  
  invisible(streams)
  
  if(ncol(xVcl)==1) xVcl = xVcl[,1]
  
  (1/rate) * xVcl
  
}

