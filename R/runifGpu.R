#' @title runifGpu
#' @description Generate uniform random numbers on a GPU
#' @param n A number or a vector specifying the size of output vector or matrix
#' @param streams Streams object. 
#' @param Nglobal NDRange of work items for use
#' @param type Precision type of random numbers, "double" or "float" or "integer", default is double
#' @param verbose if TRUE, print extra information. Default is set to 0.
#' @import gpuR
#' @importFrom utils capture.output
#' @return A vclVector or vclMatrix of uniform random numbers
#' @examples  
#' library('clrng')
#' library('gpuR')
#' streams <- createStreamsGpu(8)
#' as.vector(runifGpu(5, streams, Nglobal=c(4,2)))
#' as.matrix(runifGpu(c(2,2), streams, Nglobal=c(2,4), type="float"))
#' @useDynLib clrng
#' @export



runifGpu = function(
  n, 
  streams, 
  Nglobal,
  type=c("float", "double", "integer")[1+gpuInfo()$double_support],
  verbose=FALSE) {
  
  
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














  