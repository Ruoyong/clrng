#' @title createStreamsGpu
#' @description Generate streams on GPU device
#' @param n number of streams to create
#' @param initial Initial state of the first stream, length 6, recycled if shorter
#' @return A stream object of class 'vclMatrix' on GPU
#' @examples
#' myStreamsGpu = createStreamsGpu(n=4, initial=c(12345,12345))
#' t(as.matrix(myStreamsGpu))
#' myStreamsGpu2 = createStreamsGpu(n=4)
#' t(as.matrix(myStreamsGpu2))
#' @useDynLib clrng
#' @export





createStreamsGpu = function(n, 
                            initial=NULL){
  
  # if(missing(initial)) {
  #   seed = as.integer(as.integer(2^31-1)*(2*stats::runif(6) - 1) ) 
  #   seedVec <- gpuR::vclVector(seed, type="integer") 
  # }else{
  #   seed = rep_len(initial, 6)
  #   seedVec <- gpuR::vclVector(as.integer(seed), type="integer")  
  # }
  
  if(!is.null(initial)){
    
    if(length(initial) != 6){
      message('initial seed should be a vector of 6 integers!')
      initial = rep_len(initial, 6)
    }
    # Check that the seeds have valid values
    if(any(initial < 0))
      stop('CLRNG_INVALID_SEED')
    
    
    if(all(initial[1:3] == c(0,0,0)) | all(initial[4:6] == c(0,0,0)))
      stop('CLRNG_INVALID_SEED')
    
    
    initial = as.integer(initial)
  }else{
    initial = as.integer(rep(12345,6))
  }
  
  streamsMat<-gpuR::vclMatrix(0L, nrow=as.integer(n), ncol=12, type="integer")
  
  CreateStreamsGpuBackend(initial, streamsMat, keepInitial=1)
  
  streamsMat
  
}









