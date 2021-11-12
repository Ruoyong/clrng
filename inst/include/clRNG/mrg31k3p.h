/*
 ************************************************************************
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
 * unused original files are already removed for clrng package
 */


/*  @file mrg31k3p.h
 *  @brief Specific interface for the MRG31k3p generator
 *  @see clRNG_template.h
 */

#pragma once
#ifndef MRG31K3P_H
#define MRG31K3P_H

#include <clRNG/clRNG.h>
#include <stdio.h>   //C library to perform Input/Output operations


/*  @brief State type of a MRG31k3p stream
 *
 *  The state is a seed consisting of six unsigned 32-bit integers.
 *
 *  @see clrngStreamState
 */
typedef struct {
    /*! @brief Seed for the first MRG component
     */
    cl_uint g1[3];
    /*! @brief Seed for the second MRG component
     */
    cl_uint g2[3];
} clrngMrg31k3pStreamState;


struct clrngMrg31k3pStream_ {
//	union {
//		struct {
			clrngMrg31k3pStreamState states[3];
//		};
//		struct {
			clrngMrg31k3pStreamState current;
			clrngMrg31k3pStreamState initial;
			clrngMrg31k3pStreamState substream;
//		};
//	};
};

/*! @copybrief clrngStream
 *  @see clrngStream
 */
typedef struct clrngMrg31k3pStream_ clrngMrg31k3pStream;

struct clrngMrg31k3pStreamCreator_;
/*! @copybrief clrngStreamCreator
 *  @see clrngStreamCreator
 */
typedef struct clrngMrg31k3pStreamCreator_ clrngMrg31k3pStreamCreator;


#ifdef __cplusplus
extern "C" {
#endif

/*! @copybrief clrngCopyStreamCreator()
 *  @see clrngCopyStreamCreator()
 */
CLRNGAPI clrngMrg31k3pStreamCreator* clrngMrg31k3pCopyStreamCreator(const clrngMrg31k3pStreamCreator* creator, clrngStatus* err);



/*! @copybrief clrngAllocStreams()
 *  @see clrngAllocStreams()
 */
CLRNGAPI clrngMrg31k3pStream* clrngMrg31k3pAllocStreams(size_t count, size_t* bufSize, clrngStatus* err);
//Reserve memory space for count stream objects, without creating the stream objects. Returns a pointer to the newly allocated buffer. 




/*! @copybrief clrngCreateOverStreams()
 *  @see clrngCreateOverStreams()
 */
CLRNGAPI clrngStatus clrngMrg31k3pCreateOverStreams(clrngMrg31k3pStreamCreator* creator, size_t count, clrngMrg31k3pStream* streams);
//Create new RNG stream objects in already allocated memory.
//similar to clrngCreateStreams(), except that it does not reserve memory for the structure.
//Returns error status


/*! @copybrief clrngCreateStreams()
 *  @see clrngCreateStreams()
 */
CLRNGAPI clrngMrg31k3pStream* clrngMrg31k3pCreateStreams(clrngMrg31k3pStreamCreator* creator, size_t count, size_t* bufSize, clrngStatus* err);
//Create and return an array of count new streams using the specified creator. 
//It returns in bufSize the size of the allocated buffer, in bytes. 
//To use the default creator, put NULL as the creator parameter. To create a single stream, just put set count to 1






#ifdef __cplusplus
}
#endif



#endif
