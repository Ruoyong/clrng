###################################
### clrng global options  ###
###################################
# .onLoad <- function(libname, pkgname) {
#   # Set global options with default values
#   options(clrng.Nglobal = c(16, 8), clrng.type = "double")
#   
#   if (detectGPUs()) {
#     idx <- which(listContexts()$device_type == 'gpu')
#     if (length(idx) > 0) {
#       clrng.type <- c('float', 'double')[1 + gpuInfo(device_idx = 1L, context_idx = as.integer(idx))$double_support]
#     }
#   } else if (detectCPUs()) {
#     idx <- which(listContexts()$device_type == 'cpu')
#     if (length(idx) > 0) {
#       clrng.type <- c('float', 'double')[1 + cpuInfo(device_idx = 1L, context_idx = as.integer(idx))$double_support]
#     }
#   } else {
#     packageStartupMessage("No CPU nor GPU found on this platform. Setting clrng.type to 'float'.")
#     options(clrng.type = 'float')
#   }
# }    

.onLoad <- function(libname, pkgname) {
  # Set global options with default values
  options(clrng.Nglobal = c(16, 8))
  if (!(currentDevice()$device_type %in% c('cpu', 'gpu'))){
      options(clrng.type = 'float')
    }else{
  options(clrng.type = c('float', 'double')[1 + gpuR::deviceHasDouble()])
  }
}
  
  









