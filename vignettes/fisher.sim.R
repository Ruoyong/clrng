## ----packages, results='hide'-------------------------------------------------
library("clrng")

## ----memoryAvailable, echo=TRUE, results='hide'-------------------------------
gpuInfo()$deviceName

## ----teaTasting, eval=T-------------------------------------------------------
TeaTasting <-matrix(c(3, 1, 1, 3),nrow=2)
TeaTasting

## Using the R function 
fisher.test(TeaTasting)$p.value
## 0.4857143

