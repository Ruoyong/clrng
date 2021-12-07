/*
 ***********************************************************************
 Copyright (c) 2015 Advanced Micro Devices, Inc. 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without 
 modification, are permitted provided that the following conditions 
 are met:
 
 1. Redistributions of source code must retain the above copyright 
 notice, this list of conditions and the following disclaimer.
 
 2. Redistributions in binary form must reproduce the above copyright 
 notice, this list of conditions and the following disclaimer in the 
 documentation and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR 
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT 
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY 
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT 
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE 
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 ***********************************************************************
 */
/*
 * unused original files are already removed
 */



#include <clRNG/mrg31k3p.h>

#include <clRNG/private.h>
#include <stdlib.h>

#if defined ( WIN32 )
#define __func__ __FUNCTION__
#endif

struct clrngMrg31k3pStreamCreator_ {
	clrngMrg31k3pStreamState initialState;
	clrngMrg31k3pStreamState nextState;
	/*! @brief Jump matrices for advancing the initial seed of streams
	 */
	cl_uint nuA1[3][3];
	cl_uint nuA2[3][3];
};

#define MODULAR_NUMBER_TYPE cl_uint
#define MODULAR_FIXED_SIZE 3
#include "../include/clRNG/modularHost.c.h"

// code that is common to host and device
#include "../include/clRNG/private/mrg31k3p.c.h"



// /*! @brief Matrices to advance to the next state
//  */
// static cl_uint mrg31k3p_A1p0[3][3] = {
//     {0, 4194304, 129},
//     {1, 0, 0},
//     {0, 1, 0}
// };
// 
// static cl_uint mrg31k3p_A2p0[3][3] = {
//     {32768, 0, 32769},
//     {1, 0, 0},
//     {0, 1, 0}
// };


// /*! @brief Inverse of mrg31k3p_A1p0 mod mrg31k3p_M1
//  *
//  *  Matrices to go back to the previous state.
//  */
// static cl_uint invA1[3][3] = {
// 	{ 0, 1, 0 },
// 	{ 0, 0, 1 },
// 	{ 1531538725, 0, 915561289 }
// };
// 
// // inverse of mrg31k3p_A2p0 mod mrg31k3p_M2
// static cl_uint invA2[3][3] = {
// 	{ 0, 1, 0 },
// 	{ 0, 0, 1 },
// 	{ 252696625, 252696624, 0 }
// };


/*! @brief Default initial seed of the first stream
 */
#define BASE_CREATOR_STATE { { 12345, 12345, 12345 }, { 12345, 12345, 12345 } }
/*! @brief Jump matrices for \f$2^{134}\f$ steps forward
 */
#define BASE_CREATOR_JUMP_MATRIX_1 { \
        {1702500920, 1849582496, 1656874625}, \
        { 828554832, 1702500920, 1512419905}, \
        {1143731069,  828554832,  102237247} }
#define BASE_CREATOR_JUMP_MATRIX_2 { \
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
static clrngMrg31k3pStreamCreator defaultStreamCreator = {
	BASE_CREATOR_STATE,
	BASE_CREATOR_STATE,
	BASE_CREATOR_JUMP_MATRIX_1,
	BASE_CREATOR_JUMP_MATRIX_2
};


clrngMrg31k3pStreamCreator* clrngMrg31k3pCopyStreamCreator(const clrngMrg31k3pStreamCreator* creator, clrngStatus* err)
{
	clrngStatus err_ = CLRNG_SUCCESS;

	// allocate creator
	clrngMrg31k3pStreamCreator* newCreator = (clrngMrg31k3pStreamCreator*)malloc(sizeof(clrngMrg31k3pStreamCreator));

	if (newCreator == NULL)
		// allocation failed
		err_ = clrngSetErrorString(CLRNG_OUT_OF_RESOURCES, "%s(): could not allocate memory for stream creator", __func__);
	else {
	    if (creator == NULL)
		creator = &defaultStreamCreator;
	    // initialize creator
	    *newCreator = *creator;
	}

	// set error status if needed
	if (err != NULL)
		*err = err_;

	return newCreator;
}


clrngMrg31k3pStream* clrngMrg31k3pAllocStreams(size_t count, size_t* bufSize, clrngStatus* err)
{
	clrngStatus err_ = CLRNG_SUCCESS;
	size_t bufSize_ = count * sizeof(clrngMrg31k3pStream);

	// allocate streams
	clrngMrg31k3pStream* buf = (clrngMrg31k3pStream*)malloc(bufSize_);

	if (buf == NULL) {
		// allocation failed
		err_ = clrngSetErrorString(CLRNG_OUT_OF_RESOURCES, "%s(): could not allocate memory for streams", __func__);
		bufSize_ = 0;
	}

	// set buffer size if needed
	if (bufSize != NULL)
		*bufSize = bufSize_;

	// set error status if needed
	if (err != NULL)
		*err = err_;

	return buf;
}


static clrngStatus mrg31k3pCreateStream(clrngMrg31k3pStreamCreator* creator, clrngMrg31k3pStream* buffer)
{
	//Check params
	if (buffer == NULL)
		return clrngSetErrorString(CLRNG_INVALID_VALUE, "%s(): buffer cannot be NULL", __func__);

	// use default creator if not given
	if (creator == NULL)
		creator = &defaultStreamCreator;

	// initialize stream
	buffer->current = buffer->initial = buffer->substream = creator->nextState;

	// advance next state in stream creator
	modMatVec(creator->nuA1, creator->nextState.g1, creator->nextState.g1, mrg31k3p_M1);
	modMatVec(creator->nuA2, creator->nextState.g2, creator->nextState.g2, mrg31k3p_M2);

	return CLRNG_SUCCESS;
}

clrngStatus clrngMrg31k3pCreateOverStreams(clrngMrg31k3pStreamCreator* creator, size_t count, clrngMrg31k3pStream* streams)
{
	// iterate over all individual stream buffers
	for (size_t i = 0; i < count; i++) {

		clrngStatus err = mrg31k3pCreateStream(creator, &streams[i]);

		// abort on error
		if (err != CLRNG_SUCCESS)
			return err;
	}

	return CLRNG_SUCCESS;
}

//this one used
clrngMrg31k3pStream* clrngMrg31k3pCreateStreams(clrngMrg31k3pStreamCreator* creator, size_t count, size_t* bufSize, clrngStatus* err)
{
	clrngStatus err_;
	size_t bufSize_;
	clrngMrg31k3pStream* streams = clrngMrg31k3pAllocStreams(count, &bufSize_, &err_);

	if (err_ == CLRNG_SUCCESS)
		err_ = clrngMrg31k3pCreateOverStreams(creator, count, streams);

	if (bufSize != NULL)
		*bufSize = bufSize_;

	if (err != NULL)
		*err = err_;

	return streams;
}




















