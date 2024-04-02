#' @title runifGpu
#' @description Generate uniform random numbers parallely on a GPU
#' @param n a number or numeric vector specifying the size of output vector or matrix
#' @param streams a vclMatrix of streams. 
#' @param Nglobal a (non-empty) integer vector specifying size of work items for use, with default value from global option 'Nglobal'
#' @param type a character string specifying "double" or "float" of random numbers, with default value from global option 'type'
#' @param verbose a logical value, if TRUE, print extra information, with default value from global option 'verbose'
#' @import gpuR
#' @importFrom utils capture.output
#' 
#' @details \code{type} specifies the precision type of random numbers. If GPU supports "double", default is "double", otherwise, default is "single"
#' 
#' @return a vclVector or vclMatrix of uniform random numbers
#' @examples  
#' library('clrng')
#' currentDevice()
#' streams <- createStreamsGpu(8)
#' as.vector(runifGpu(5, streams))
#' 
#' #Change global options
#’ options(type="float")
#' as.matrix(runifGpu(c(2,2), streams))
#' @useDynLib clrng
#' @export


runifGpu = function(
  n, 
  streams, 
  Nglobal = NULL,
  type = NULL,
  verbose = NULL) {
   
  #print(getOption('Nglobal'))

   if (is.null(Nglobal)) Nglobal <- getOption('Nglobal')
   if (is.null(type))    type <- getOption('type')
   if (is.null(verbose)) verbose <- getOption('verbose')
  
  if(length(n)>=3){
    stop("'n' has to be a vector of no more than two elements")
  }
  if(length(n)==0){
    stop("specify the number of rows and columns of the output matrix")
  }
  if(length(n)==1){
    n<-c(n,1)
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
   #    initial <- as.integer(rep(12345,6))
   #    streams <- vclMatrix(0L, nrow=prod(Nglobal), ncol=12, type="integer")
   #    CreateStreamsGpuBackend(initial, streams, keepInitial=1)
   #    currentCreator <- streams[nrow(streams),]
   #    assign(".Random.seed.clrng",  currentCreator, envir = .GlobalEnv)
   # }
    
   if(prod(Nglobal) > nrow(streams)){
    warning("the number of streams created should always equal (or exceed)
             the maximum number of work items likely to be used")
   }

  xVcl<-gpuR::vclMatrix(0L, nrow=n[1], ncol=n[2], type=type[1])    
  
  
  gpuRnBackend(xVcl, streams, Nglobal,"uniform", verbose) 
  
  invisible(streams)
  
  if(ncol(xVcl)==1) {
    if (type == "float"){
      invisible(capture.output(xVcl <- as.vclVector(xVcl)))     # an unneeded message from gpuR if float
    }else{
      xVcl <- as.vclVector(xVcl)
    }
      
  }
  
  xVcl
  
}














  