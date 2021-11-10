#' @title Create streams on GPU
#'
#' @description Create streams in R.
#' 
#' @param n number of streams to create.
#' @param seed the initial seed of streams.
#' @return A stream object on GPU.
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
  streamsR<-gpuR::vclMatrix(0L, nrow=as.integer(n), ncol=12, type="integer")
  
  CreateStreamsGpuBackend(seedVec, streamsR, keepInitial=1)
  
  streamsR
  
}









