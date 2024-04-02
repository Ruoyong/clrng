## ----packages, results='hide'-------------------------------------------------
library('clrng')

## ----setType------------------------------------------------------------------
options(type='double')

## ----unif, eval=TRUE----------------------------------------------------------
setBaseCreator(rep(12235,6))
# Generating random uniforms stored in a vector
myStreamsGpu = clrng::createStreamsGpu(16)
as.vector(clrng::runifGpu(10, myStreamsGpu, Nglobal=c(4,4),verbose=2))

# Generating random uniforms stored in a 100 x 100 matrix 
myStreamsGpu2 = clrng::createStreamsGpu(n=64*64)
b<-clrng::runifGpu(c(100,100), myStreamsGpu2, Nglobal=c(64,64))
bvector<-as.vector(as.matrix(b))

# plot the histogram
hist(bvector, breaks=40)
# check the quantiles of the produced random numbers
quantile(bvector)

