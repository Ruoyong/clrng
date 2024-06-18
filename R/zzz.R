.onLoad <- .onAttach  <- function(libname, pkgname) {

	if (!identical(Sys.info()["sysname"], "Linux")) {
  		warning("This package is only supported on Linux, it is unlikely to work on macOS", call. = FALSE)
	}

}