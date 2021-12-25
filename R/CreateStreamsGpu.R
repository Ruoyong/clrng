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
                            initial=sample.int(2147483647, 6, replace = TRUE)){
  
  # if(missing(initial)) {
  #   seed = as.integer(as.integer(2^31-1)*(2*stats::runif(6) - 1) ) 
  #   seedVec <- gpuR::vclVector(seed, type="integer") 
  # }else{
  #   seed = rep_len(initial, 6)
  #   seedVec <- gpuR::vclVector(as.integer(seed), type="integer")  
  # }
  
  initial = rep_len(initial, 6)
  seedVec <- gpuR::vclVector(as.integer(initial), type="integer") 
  streamsMat<-gpuR::vclMatrix(0L, nrow=as.integer(n), ncol=12, type="integer")
  
  CreateStreamsGpuBackend(seedVec, streamsMat, keepInitial=1)
  
  streamsR
  
}









