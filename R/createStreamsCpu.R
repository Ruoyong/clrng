#' @title createStreamsCpu
#' @description Create streams stored on the CPU
#' @param n Number of streams to create, default is 1024
#' @return A stream object on CPU
#' @examples 
#' library(clrng)
#' library(gpuR)
#' t(createStreamsCpu(n=5))
#' ###GPU streams
#' myStreamsGpu1 = vclMatrix(createStreamsCpu(n=4))
#' 
#' @useDynLib clrng



#' @export
 
createStreamsCpu = function(n=1024){
  
  n = as.integer(n)
  
  if(!exists(".Random.seed.clrng")) {
    assign(".Random.seed.clrng", setBaseCreator())
  } 
  
  
  streamsR<-gpuR::vclMatrix(0L, nrow=as.integer(n), ncol=12, type="integer")
  streamsCpu<- matrix(0L, nrow=as.integer(n), ncol=12)
  
  currentCreator = CreateStreamsBackend(
    .Random.seed.clrng,    
    streamsR,
    streamsCpu,
    onGpu=FALSE,
    keepInitial=TRUE)
  # 
  assign(".Random.seed.clrng",  currentCreator, envir = .GlobalEnv)
  streamsCpu
  
}    
     
     
   

