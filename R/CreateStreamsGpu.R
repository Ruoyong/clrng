#' @title setBaseCreator
#' @description Set the initial seed of the package or stream
#' @param initial Initial state of the first stream, length 6, recycled if shorter
#' @return A stream object of class 'vclMatrix' on GPU
#' @examples
#' setBaseCreator(c(111,222,333,444,555,666))
#' @useDynLib clrng
#' @export


    setBaseCreator <- function(initial = rep(12345,6)) {
      
      if(length(initial) != 6){
        # message('initial seed should be a vector of 6 integers!')
        initial = rep_len(initial, 6)
      }
      # Check that the seeds have valid values
      if(any(initial < 0))
        stop('CLRNG_INVALID_SEED')
  
  
      if(all(initial[1:3] == c(0,0,0)) | all(initial[4:6] == c(0,0,0)))
        stop('CLRNG_INVALID_SEED')
  
      initial = as.integer(initial)

      assign(".Random.seed.clrng", initial, envir = .GlobalEnv)
    }

    
    
    
    
#' @title createStreamsGpu
#' @description Generate streams on GPU device
#' @param n number of streams to create
#' @return A stream object of class 'vclMatrix' on GPU
#' @examples
#' setBaseCreator(rep(12345,6))
#' myStreamsGpu = createStreamsGpu(n=4)
#' t(as.matrix(myStreamsGpu))
#' myStreamsGpu2 = createStreamsGpu(n=4)
#' t(as.matrix(myStreamsGpu2))
#' @useDynLib clrng    
#' @export
    createStreamsGpu = function(n){
      
      streamsMat<-gpuR::vclMatrix(0L, nrow=as.integer(n), ncol=12, type="integer")
      
      if(!exists(".Random.seed.clrng")) {
        assign(".Random.seed.clrng", setBaseCreator())
      } 
  
  # if(missing(initial)) {
  #   seed = as.integer(as.integer(2^31-1)*(2*stats::runif(6) - 1) ) 
  #   seedVec <- gpuR::vclVector(seed, type="integer") 
  # }else{
  #   seed = rep_len(initial, 6)
  #   seedVec <- gpuR::vclVector(as.integer(seed), type="integer")  
  # }
  
  # if(!is.null(initial)){
    

  # }else{
  #   initial = as.integer(rep(12345,6))
  # }
  

  
      currentCreator = CreateStreamsGpuBackend(.Random.seed.clrng, streamsMat, keepInitial=TRUE)
  
      #currentCreator = streamsMat[nrow(streamsMat),]
      
      assign(".Random.seed.clrng",  currentCreator, envir = .GlobalEnv)

      streamsMat
  
    }









