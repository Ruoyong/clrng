#include "gpuRandom.hpp"
//#include <CL/mrg31k3pkernelStringSeparate.hpp>


using namespace Rcpp;

/*
 //matrix ->clRNG streams
 void convertMatclRng(Rcpp::IntegerMatrix Sin, clrngMrg31k3pStream* streams){
 
 int Ditem,Delement,Dcis,Dg;
 int numWorkItems = Sin.nrow();
 
 for(Ditem =0;Ditem < numWorkItems;Ditem++){
 for(Delement=0;Delement < 3;Delement++){
 
 Dcis=0;
 Dg=0;
 streams[Ditem].current.g1[Delement] = Sin(Ditem,Dcis*6 + Dg*3 + Delement);
 Dg=1;
 streams[Ditem].current.g2[Delement] = Sin(Ditem,Dcis*6 + Dg*3 + Delement);
 
 Dcis=1;
 Dg=0;
 streams[Ditem].initial.g1[Delement] = Sin(Ditem,Dcis*6 + Dg*3 + Delement);
 Dg=1;
 streams[Ditem].initial.g2[Delement]=Sin(Ditem,Dcis*6 + Dg*3 + Delement);
 
 Dcis=2;
 Dg=0;
 streams[Ditem].substream.g1[Delement]=Sin(Ditem,Dcis*6 + Dg*3 + Delement);
 Dg=1;
 streams[Ditem].substream.g2[Delement] = Sin(Ditem,Dcis*6 + Dg*3 + Delement);
 }
 }
 }
 
 */

// clRNG -> Matrix
void convertclRngMat(clrngMrg31k3pStream* streams, Rcpp::IntegerMatrix result) {
  
  int numWorkItems = result.nrow();
  int Ditem,Delement,Dcis,Dg;
  for(Ditem =0;Ditem < numWorkItems;Ditem++){
    for(Delement=0;Delement < 3;Delement++){
      
      Dcis=0;
      Dg=0;
      result(Ditem, Dcis*6 + Dg*3 + Delement) = streams[Ditem].current.g1[Delement];//0,0; 0,1
      Dg=1;
      result(Ditem,Dcis*6 + Dg*3 + Delement) = streams[Ditem].current.g2[Delement];//0,3; 0,4
      
      Dcis=1;
      Dg=0;
      result(Ditem,Dcis*6 + Dg*3 + Delement) = streams[Ditem].initial.g1[Delement];//0,6; 0,7
      Dg=1;
      result(Ditem,Dcis*6 + Dg*3 + Delement) = streams[Ditem].initial.g2[Delement];//0,9; 0,10
      
      // Dcis=2;
      // Dg=0;
      // result(Ditem,Dcis*6 + Dg*3 + Delement) = streams[Ditem].substream.g1[Delement];//0,12
      // Dg=1;
      // result(Ditem,Dcis*6 + Dg*3 + Delement) = streams[Ditem].substream.g2[Delement];//0,15
      
    }
  }
  
}




/*! @brief Default initial seed of the first stream
 */
//#define BASE_CREATOR_STATE { {12345, 12345, 12345 }, { 12345, 12345, 12345 } }
/*! @brief Jump matrices for \f$2^{134}\f$ steps forward
 */
#define BASE_CREATOR_JUMP_MATRIX_1 {  \
{1702500920, 1849582496, 1656874625}, \
{ 828554832, 1702500920, 1512419905}, \
{1143731069,  828554832,  102237247} }
#define BASE_CREATOR_JUMP_MATRIX_2 {  \
{ 796789021, 1464208080,  607337906}, \
{1241679051, 1431130166, 1464208080}, \
{1401213391, 1178684362, 1431130166} }

/*! @brief Default stream creator (defaults to \f$2^{134}\f$ steps forward)
 *
 *  Contains the default seed and the transition matrices to jump \f$\nu\f$ steps forward;
 *  adjacent streams are spaced nu steps apart.
 *  The default is \f$nu = 2^{134}\f$.
 *  The default seed is \f$(12345,12345,12345,12345,12345,12345)\f$.
 */
struct clrngMrg31k3pStreamCreator_ {
  clrngMrg31k3pStreamState initialState;
  clrngMrg31k3pStreamState nextState;
  /*! @brief Jump matrices for advancing the initial seed of streams
   */
  cl_uint nuA1[3][3];
  cl_uint nuA2[3][3];
};        
// static clrngMrg31k3pStreamCreator defaultStreamCreator = {
//   BASE_CREATOR_STATE,
//   BASE_CREATOR_STATE,
//   BASE_CREATOR_JUMP_MATRIX_1,
//   BASE_CREATOR_JUMP_MATRIX_2
// };









clrngMrg31k3pStreamState SetBaseCreatorState(Rcpp::IntegerVector seed){
  
  int Ditem;
  
  clrngMrg31k3pStreamState BASE_CREATOR_STATE;
  
  for(Ditem = 0; Ditem < 3; Ditem++) {
    BASE_CREATOR_STATE.g1[Ditem] = seed[Ditem];
    BASE_CREATOR_STATE.g2[Ditem] = seed[Ditem+3];
  }
  
  return BASE_CREATOR_STATE;
}




// [[Rcpp::export]]
Rcpp::IntegerMatrix  createStreamsCpuBackend(
    Rcpp::IntegerVector n,
    Rcpp::IntegerVector initial){  //Rcpp::Nullable<Rcpp::IntegerVector>
  
  
  Rcpp::IntegerMatrix result=Rcpp::IntegerMatrix(n[0], 12L);
  
  colnames(result) = CharacterVector::create(
    "current.g1.1", "current.g1.2", "current.g1.3", "current.g2.1", "current.g2.2", "current.g2.3",
    "initial.g1.1", "initial.g1.2", "initial.g1.3", "initial.g2.1", "initial.g2.2", "initial.g2.3");
  
  
  size_t streamBufferSize;
  clrngStatus err;
  
  clrngMrg31k3pStream* streams;
  
  // if (!initial_.isNotNull()){
  //   streams = clrngMrg31k3pCreateStreams(&defaultStreamCreator, n[0], &streamBufferSize, &err);//line 299 in mrg31k3p.c
  // }else{
  //   Rcpp::IntegerVector initial(initial_);
  clrngMrg31k3pStreamState  BASE_CREATOR_STATE_FromUser = SetBaseCreatorState(initial);
  //Rcpp::Rcout << BASE_CREATOR_STATE_FromUser  << std::endl;
  //#undef BASE_CREATOR_STATE
  #define BASE_CREATOR_STATE BASE_CREATOR_STATE_FromUser
  
  static clrngMrg31k3pStreamCreator UserStreamCreator = {
    BASE_CREATOR_STATE,
    BASE_CREATOR_STATE,
    BASE_CREATOR_JUMP_MATRIX_1,
    BASE_CREATOR_JUMP_MATRIX_2
  };
  
  streams = clrngMrg31k3pCreateStreams(&UserStreamCreator, n[0], &streamBufferSize, &err);//line 299 in mrg31k3p.c
  
  
  // Rcpp::Rcout << "a" << streamCreatorHere.initialState.g1[0]<< " " << streamCreatorHere.initialState.g1[1]<< " " << streamCreatorHere.initialState.g1[2]<< "\n";
  // Rcpp::Rcout << "b" << streamCreatorHere.initialState.g2[0]<< " " << streamCreatorHere.initialState.g2[1]<< " " << streamCreatorHere.initialState.g2[2]<< "\n";
  convertclRngMat(streams, result);
  
  return result;
}
















