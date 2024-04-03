//#pragma OPENCL EXTENSION cl_khr_fp64 : enable

//#include <clRNG/clRNG.h>
#include <Rcpp.h>
#include <string>
//#include <clRNG/mrg31k3p.h>


#include <dynMatrix/dynVCLMatGeostatsgpu.hpp>
#include <dynMatrix/dynVCLVecGeostatsgpu.hpp>
#include "viennacl/linalg/sum.hpp"
#include "viennacl/ocl/backend.hpp"

//from typeDef.cpp
template <typename T> std::string openclTypeString();




// clRNG -> Matrix
//void convertclRngMat(clrngMrg31k3pStream* streams, Rcpp::IntegerMatrix result);



std::string mrg31k3pString();


double logfactsum(
    viennacl::matrix<int>  &x, //viennacl::vector_base<int>  rowSum,viennacl::vector_base<int>  colSum,   
    Rcpp::IntegerVector numWorkItems,
    int ctx_id);

























