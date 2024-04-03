#' @title logfactSum
#' @description Computes the log-factorial of a table
#' 
#' @param x A matrix of integers
#' @param Nglobal Size of the index space for use
#' @return Sum of log-factorials of elements of the matrix
#' 
#' @examples 
#' x<-matrix(c(1:36), 6,6)
#' logfactSum(x, c(2,2))
#' #if matrix is not of intergers, a warning will be displayed
#' x2<-matrix(c(1.1,2.1,3.1,4.1,5.1,6.1,7.1,8.1,9.1), 3,3)
#' !is.integer(x2)
#' logfactSum(x2, c(16,16))
#' @useDynLib clrng
#' @export




logfactSum <- function(x,      # an R matrix
                       Nglobal) {
  
  
  if(any(dim(x) < 2L))
   stop("table must have at least 2 rows and columns")
  
  if(!is.integer(x)) {
          xo <- x
          x <- round(x)
              if(any(x > .Machine$integer.max))
              stop("'x' has entries too large to be integer")
          if(!identical(TRUE, (ax <- all.equal(xo, x))))
           warning(gettext("matrix has been rounded to integer", ax), domain = NA)
           storage.mode(x) <- "integer"
     }
    
    
  x <- gpuR::vclMatrix(x,type="integer")
  
  
  result <- logfactsumBackend(x, Nglobal)
  
  
  result
  
  
  
}




