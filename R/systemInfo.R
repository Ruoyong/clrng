#' @title print_system_info
#' @description This function prints operating system, CPU, GPU, and OpenCL version information.
#' @return A character vector containing system information.
#' 
#' @export
#' @useDynLib clrng

print_system_info <- function() {
  .Call("_printSystemInfo")
}