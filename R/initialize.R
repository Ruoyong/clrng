###################################
### clrng global options  ###
###################################

.onLoad <- function(libname, pkgname) {
  # Set global options with default values
  
  options(clrng.Nglobal = c(16,8), 
          clrng.type = c('float','double')[1+gpuR::deviceHasDouble()]
  )
  
}


