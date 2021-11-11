#' @title createStreamsCpu
#' @description Create streams stored on the CPU
#' @param n Number of streams to create
#' @param initial Initial state of the first stream, length 6, recycled if shorter
#' @return A stream object on CPU
#' @useDynLib clrng
#' @author Ruoyong Xu
#' @export


createStreamsCpu = function(n, 
                            initial=sample.int(2147483647, 6, replace = TRUE)){
  
  # if(missing(initial)) {
  #   initial = as.integer(as.integer(2^31-1)*(2*stats::runif(6) - 1) )
  # }else{
  #   initial = rep_len(initial, 6)
  # }
  
  initial = rep_len(initial, 6)
  streamsR <- createStreamsCpuBackend(n, initial)
  
  streamsR
  
}

