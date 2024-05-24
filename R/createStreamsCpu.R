#' @title createStreamsCpu
#' @description Create streams stored on the CPU.
#' @param n a integer specifying number of streams to create, default is the number of total work items in use.
#' @return an R matrix of streams on CPU.
#' 
#' @examples 
#' library(clrng)
#' t(createStreamsCpu(n=5))
#' ## GPU streams
#' myStreamsGpu = vclMatrix(createStreamsCpu(n=4))
#' 
#' @useDynLib clrng



#' @export

createStreamsCpu = function(n=prod(getOption('clrng.Nglobal'))){
  
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





   

