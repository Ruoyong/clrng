###################################
### clrng global options  ###
###################################

.onLoad <- function(libname, pkgname) {
  # Set global options with default values
  gpuR::setContext(grep("gpu", listContexts()$device_type)[1])
  
  options(Nglobal = c(2,4), 
          type = c('float','double')[1+gpuR::gpuInfo()$double_support],
          returnStatistics = FALSE,
          verbose = FALSE)
}


