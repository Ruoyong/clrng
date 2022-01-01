#' @title createStreamsCpu
#' @description Create streams stored on the CPU
#' @param n Number of streams to create
#' @param initial Initial state of the first stream, length 6, recycled if shorter
#' @return A stream object on CPU
#' @examples 
#' library(clrng)
#' library(gpuR)
#' t(createStreamsCpu(n=4, initial=12345))
#' ###GPU streams
#' myStreamsGpu1 = vclMatrix(createStreamsCpu(n=4, initial=12345))
#' 
#' @useDynLib clrng



#' @export
createStreamsCpu = function(n){
  
  
    if(!exists(".Random.seed.clrng")) {
      assign(".Random.seed.clrng", setBaseCreator())
    } 
  
  # if(missing(initial)) {
  #   initial = as.integer(as.integer(2^31-1)*(2*stats::runif(6) - 1) )
  # }else{
  #   initial = rep_len(initial, 6)
  # }
  #if(!is.null(initial)){
    
    # if(length(initial) != 6){
    # # message('initial seed should be a vector of 6 integers!')
    # initial = rep_len(initial, 6)
    # }
    # # Check that the seeds have valid values
    # if(any(initial < 0))
    #   stop('CLRNG_INVALID_SEED')
    # 
    # 
    # if(all(initial[1:3] == c(0,0,0)) | all(initial[4:6] == c(0,0,0)))
    #   stop('CLRNG_INVALID_SEED')
    # 
    # 
    # initial = as.integer(initial)

  
    streamsR <- createStreamsCpuBackend(n, .Random.seed.clrng)
    currentCreator <- streamsR[nrow(streamsR),]
    
    assign(".Random.seed.clrng",  currentCreator, envir = .GlobalEnv)
    streamsR
  
   }

     
     
     
     
# clrngSetBaseCreatorState <- function(initial){
#   
#   # Check that the seeds have valid values
#   initial = rep_len(initial, 6)
#   if(!identical(initial, as.integer(initial))){
#     stop('inital must contain integer values!')
#   }
#  
#   if(any(initial < 0)){
#     stop('inital must contain unsigned integer values!')
#   }
#   
#   if(all(initial[1:3] == c(0,0,0) | all(initial[4:6] == c(0,0,0)){
#     stop('CLRNG_INVALID_SEED')
#   }
#   
# }

     
     
     
     
     
     
     
     
     
