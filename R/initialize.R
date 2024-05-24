###################################
### clrng global options  ###
###################################

.onLoad <- function(libname, pkgname) {
  # Set global options with default values
    options(clrng.Nglobal = c(16, 8))
    if (detectGPUs()) {
      
      idx <- which(listContexts()$device_type == 'gpu')
      double_support = 1+gpuInfo(device_idx = 1L, context_idx = as.integer(idx))$double_support
      
    } else if (detectCPUs()) {
      idx <- which(listContexts()$device_type == 'cpu')
      double_support = 1+cpuInfo(device_idx = 1L, context_idx = as.integer(idx))$double_support
      
    } else{
      message("No CPU nor GPU found on this platform.")
      options(clrng.type = 'float')
      return()
    }
    clrng.type <- ifelse(double_support, "double", "float")
    options(clrng.type = clrng.type)
}
      
      
    


