#define __CL_ENABLE_EXCEPTIONS
#include <CL/cl.hpp>
#include <Rcpp.h>
#include <vector>
#include <string>

// #define mrg31k3p_M1 2147483647             /* 2^31 - 1 */
// #define mrg31k3p_M2 2147462579             /* 2^31 - 21069 */


std::string streamsString(int NpadStreams, 
                          const int keepInitial) {  
  
  
  std::string result = "";
  
  
  result += 
    "#define NpadStreams " + std::to_string(NpadStreams) + "\n"
    "#define mrg31k3p_M1 2147483647 \n"
    "#define mrg31k3p_M2 2147462579 \n\n\n";
  
  
  result += "__constant ulong jmatrix[18]= {1702500920, 1849582496, 1656874625,\n"
  " 828554832, 1702500920, 1512419905,\n"
  " 1143731069,  828554832,  102237247,\n"
  " 796789021, 1464208080,  607337906, \n"
  " 1241679051, 1431130166, 1464208080, \n"
  " 1401213391, 1178684362, 1431130166};\n\n\n";
  
  
  /* 
   result += "__constant cl_uint jmatrix[18]= {1, 2, 3,\n"
   " 4, 5, 6,\n"
   " 7,  8, 9,\n"
   "1, 0, 0,\n"
   " 0, 1, 0,\n"
   " 0,  0,  1 };\n\n\n";
   */  
  
  
  result += 
  "\n__kernel void createStreams(\n"    
  "__global uint *creatorInitialGlobal, \n"
  "__global uint *streams,\n"
  "int Nstreams){\n";
  
  
  result +=
    "uint creatorNextState[6], creatorCurrentState[6];\n"  
    "int i, row, col, Dstream;\n"
    "ulong acc; \n\n\n";
  
  
  
  
  if (keepInitial >= 1){
    result +=  
      " for (i=0; i<6; i++) {\n"
      "creatorCurrentState[i] = creatorInitialGlobal[i];\n"
      "}\n";
    
  }else if (keepInitial == 0) {
    
    result +=     
      // modMatVec(creator->nuA1, creator->nextState.g1, creator->nextState.g1, mrg31k3p_M1);
      "for (row=0; row<3; row++){\n"
      "acc = 0;\n"
      "for (col=0; col<3; col++){\n"
      "acc += (jmatrix[3 * row + col] * ( (ulong) creatorInitialGlobal[col]) ) % mrg31k3p_M1;\n"
      " }\n"
      //"creatorCurrentState[row] = acc; \n"
      "creatorCurrentState[row] = (uint) (acc % mrg31k3p_M1);\n"
      
      "}\n"
      
      
      // modMatVec(creator->nuA2, creator->nextState.g2, creator->nextState.g2, mrg31k3p_M2);
      "for (row=3; row<6; row++){\n"
      " acc = 0;\n"
      "for (col=0; col<3; col++){\n"
      "acc += (jmatrix[3 * row + col] * ((ulong) creatorInitialGlobal[col+3])) % mrg31k3p_M2;\n"
      "}\n"
      //"creatorCurrentState[row] = acc; \n"
      "creatorCurrentState[row] = (uint) (acc % mrg31k3p_M2);\n"
      
      "}\n\n";
    
  }
  
  
  result +=  
    
    "for(Dstream = 0;   Dstream < Nstreams;    Dstream++){\n\n"
    
    // upate creatorNext from creatorCurrentState,
    "for (i=0; i<6; i++) {\n"
    " streams[Dstream * NpadStreams +  i] = \n"//initial
    " streams[Dstream * NpadStreams + 6 + i] = \n"//current
    //"streams[Dstream * NpadStreams + 12 + i] = "// substream
    " creatorNextState[i] = creatorCurrentState[i];\n"
    "}\n"
    
    
    
    // Matrix-vector modular multiplication
    // modMatVec(creator->nuA1, creator->nextState.g1, creator->nextState.g1, mrg31k3p_M1);
    "for (row=0; row<3; row++){\n"
    "acc = 0;\n"
    "for (col=0; col<3; col++){\n"
    "acc += (jmatrix[3 * row + col] * ( (ulong) creatorNextState[col]) ) % mrg31k3p_M1;\n"
    " }\n"
    //"creatorCurrentState[row] = acc; \n"
    "creatorCurrentState[row] = (uint) (acc % mrg31k3p_M1);\n"
    // "creatorCurrentState[row] = fmod((float)acc, (float)mrg31k3p_M1);\n"
    "}\n"
    
    
    
    // modMatVec(creator->nuA2, creator->nextState.g2, creator->nextState.g2, mrg31k3p_M2);
    "for (row=3; row<6; row++){\n"
    " acc = 0;\n"
    "for (col=0; col<3; col++){\n"
    "acc += (jmatrix[3 * row + col] * ((ulong)creatorNextState[col+3])) % mrg31k3p_M2;\n"
    "}\n"
    // "creatorCurrentState[row] = acc; \n"
    "creatorCurrentState[row] = (uint) (acc % mrg31k3p_M2);\n"
    // "creatorCurrentState[row] = fmod((float)acc, (float)mrg31k3p_M2);\n"
    "}\n"
    
    "}\n"; // loop through streams
  
  
  result +=  
    " for (i=0; i<6; i++) {\n"
    "creatorInitialGlobal[i] = creatorCurrentState[i];\n"
    "}\n"
    
    
    
    "}\n"; 
  
  return(result);
}




#define mrg31k3p_M1 2147483647            
#define mrg31k3p_M2 2147462579   


// Function to create OpenCL buffer from Rcpp IntegerMatrix
cl_mem CreateOpenCLBufferFromRcppMatrix(Rcpp::IntegerMatrix& matrix, cl_context context, cl_int* err) {
  size_t bufferSize = matrix.nrow() * matrix.ncol() * sizeof(int);
  cl_mem buffer = clCreateBuffer(context, CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR, bufferSize, matrix.begin(), err);
  if (*err != CL_SUCCESS) {
    Rcpp::stop("Failed to create OpenCL buffer.");
  }
  return buffer;
}

// Function to create OpenCL context
cl_context CreateOpenCLContext(int ctx_id) {
  cl_int err;
  cl_platform_id platform;
  cl_uint num_platforms;
  clGetPlatformIDs(1, &platform, &num_platforms);
  
  cl_context_properties properties[] = { CL_CONTEXT_PLATFORM, (cl_context_properties)platform, 0 };
  cl_context context = clCreateContextFromType(properties, CL_DEVICE_TYPE_GPU, NULL, NULL, &err);
  if (err != CL_SUCCESS) {
    Rcpp::stop("Failed to create OpenCL context.");
  }
  
  return context;
}

// Function to create OpenCL command queue
cl_command_queue CreateOpenCLCommandQueue(cl_context context, int ctx_id) {
  cl_device_id device;
  clGetContextInfo(context, CL_CONTEXT_DEVICES, sizeof(cl_device_id), &device, NULL);
  cl_command_queue commands = clCreateCommandQueue(context, device, 0, NULL);
  if (!commands) {
    Rcpp::stop("Failed to create command queue.");
  }
  
  return commands;
}

// Function to create OpenCL kernel and execute on GPU
Rcpp::IntegerVector CreateStreamsGpu(
    Rcpp::IntegerVector creatorInitialGlobalR,
    Rcpp::IntegerMatrix streamsMat,
    const int onGpu,
    const int keepInitial,
    cl_context context,
    cl_command_queue commands,
    cl_device_id device) {
  
  static std::vector<int> creatorInitial_cpu = Rcpp::as<std::vector<int>>(creatorInitialGlobalR);
  const int Nstreams = streamsMat.nrow();
  
  if (onGpu == 1) {
    cl_int err;
    
    std::string kernelSource = streamsString(streamsMat.ncol(), keepInitial);
    const char* kernelSourceChar = kernelSource.c_str();
    
    cl_program program = clCreateProgramWithSource(context, 1, &kernelSourceChar, NULL, &err);
    if (!program) {
      Rcpp::stop("Error: Failed to create compute program!");
    }
    
    err = clBuildProgram(program, 0, NULL, NULL, NULL, NULL);
    if (err != CL_SUCCESS) {
      size_t len;
      char buffer[2048];
      clGetProgramBuildInfo(program, device, CL_PROGRAM_BUILD_LOG, sizeof(buffer), buffer, &len);
      clReleaseProgram(program);
      Rcpp::stop("Error: Failed to build program executable!\n%s", buffer);
    }
    
    cl_kernel kernel = clCreateKernel(program, "createStreams", &err);
    if (!kernel || err != CL_SUCCESS) {
      clReleaseProgram(program);
      Rcpp::stop("Error: Failed to create compute kernel!");
    }
    
    // Create OpenCL buffers directly
    cl_mem creatorInitialGlobalBuffer = clCreateBuffer(context, CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR, 6 * sizeof(int), creatorInitial_cpu.data(), &err);
    if (err != CL_SUCCESS) {
      clReleaseKernel(kernel);
      clReleaseProgram(program);
      Rcpp::stop("Error: Failed to create buffer for creatorInitialGlobal!");
    }
    
    cl_mem streamsBuffer = clCreateBuffer(context, CL_MEM_READ_WRITE, Nstreams * streamsMat.ncol() * sizeof(int), NULL, &err);
    if (err != CL_SUCCESS) {
      clReleaseMemObject(creatorInitialGlobalBuffer);
      clReleaseKernel(kernel);
      clReleaseProgram(program);
      Rcpp::stop("Error: Failed to create buffer for streams!");
    }
    
    err = clSetKernelArg(kernel, 0, sizeof(cl_mem), &creatorInitialGlobalBuffer);
    err |= clSetKernelArg(kernel, 1, sizeof(cl_mem), &streamsBuffer);
    err |= clSetKernelArg(kernel, 2, sizeof(int), &Nstreams);
    
    if (err != CL_SUCCESS) {
      clReleaseMemObject(creatorInitialGlobalBuffer);
      clReleaseMemObject(streamsBuffer);
      clReleaseKernel(kernel);
      clReleaseProgram(program);
      Rcpp::stop("Error: Failed to set kernel arguments!");
    }
    
    size_t global = Nstreams;
    err = clEnqueueNDRangeKernel(commands, kernel, 1, NULL, &global, NULL, 0, NULL, NULL);
    if (err != CL_SUCCESS) {
      clReleaseMemObject(creatorInitialGlobalBuffer);
      clReleaseMemObject(streamsBuffer);
      clReleaseKernel(kernel);
      clReleaseProgram(program);
      Rcpp::stop("Error: Failed to execute kernel!");
    }
    
    err = clEnqueueReadBuffer(commands, streamsBuffer, CL_TRUE, 0, Nstreams * streamsMat.ncol() * sizeof(int), streamsMat.begin(), 0, NULL, NULL);
    if (err != CL_SUCCESS) {
      clReleaseMemObject(creatorInitialGlobalBuffer);
      clReleaseMemObject(streamsBuffer);
      clReleaseKernel(kernel);
      clReleaseProgram(program);
      Rcpp::stop("Error: Failed to read buffer for streams!");
    }
    
    err = clEnqueueReadBuffer(commands, creatorInitialGlobalBuffer, CL_TRUE, 0, 6 * sizeof(int), creatorInitial_cpu.data(), 0, NULL, NULL);
    if (err != CL_SUCCESS) {
      clReleaseMemObject(creatorInitialGlobalBuffer);
      clReleaseMemObject(streamsBuffer);
      clReleaseKernel(kernel);
      clReleaseProgram(program);
      Rcpp::stop("Error: Failed to read buffer for creatorInitialGlobal!");
    }
    
    clReleaseMemObject(creatorInitialGlobalBuffer);
    clReleaseMemObject(streamsBuffer);
    clReleaseKernel(kernel);
    clReleaseProgram(program);
  } else {
    int i, row, col, Dstream;
    unsigned long acc;
    
    const unsigned long JUMP_MATRIX[18] = {
      1702500920, 1849582496, 1656874625,
      828554832, 1702500920, 1512419905,
      1143731069, 828554832, 102237247,
      796789021, 1464208080, 607337906,
      1241679051, 1431130166, 1464208080,
      1401213391, 1178684362, 1431130166
    };
    
    uint creatorNextState[6];
    
    for (Dstream = 0; Dstream < Nstreams; Dstream++) {
      for (i = 0; i < 6; i++) {
        streamsMat(Dstream, i) = 
          streamsMat(Dstream, 6 + i) = 
          creatorNextState[i] = creatorInitial_cpu[i];
      }
      
      for (row = 0; row < 3; row++) {
        acc = 0;
        for (col = 0; col < 3; col++) {
          acc += (JUMP_MATRIX[3 * row + col] * ( (unsigned long) creatorNextState[col] ) ) % mrg31k3p_M1;
        }
        creatorInitial_cpu[row] = (uint) (acc % mrg31k3p_M1);
      }
      
      for (row = 3; row < 6; row++) {
        acc = 0;
        for (col = 0; col < 3; col++) {
          acc += (JUMP_MATRIX[3 * row + col] * ( (unsigned long) creatorNextState[col+3]) ) % mrg31k3p_M2;
        }
        creatorInitial_cpu[row] = (uint) (acc % mrg31k3p_M2);
      }
    }
  }
  
  Rcpp::IntegerVector currentSeed(creatorInitial_cpu.begin(), creatorInitial_cpu.end());
  return currentSeed;
}

SEXP CreateStreamsTemplated(
    Rcpp::IntegerVector creatorInitialGlobalR,
    Rcpp::S4 streamsR,
    Rcpp::IntegerMatrix streamsMat,
    const int onGpu,
    const int keepInitial) {
  
  cl_int err;
  cl_device_id device;
  cl_context context;
  cl_command_queue commands;
  
  // Get OpenCL context and command queue
  cl_platform_id platform;
  err = clGetPlatformIDs(1, &platform, NULL);
  if (err != CL_SUCCESS) {
    Rcpp::stop("Error: Failed to find an OpenCL platform!");
  }
  
  err = clGetDeviceIDs(platform, CL_DEVICE_TYPE_GPU, 1, &device, NULL);
  if (err != CL_SUCCESS) {
    Rcpp::stop("Error: Failed to create a device group!");
  }
  
  context = clCreateContext(0, 1, &device, NULL, NULL, &err);
  if (!context) {
    Rcpp::stop("Error: Failed to create a compute context!");
  }
  
  commands = clCreateCommandQueue(context, device, 0, &err);
  if (!commands) {
    clReleaseContext(context);
    Rcpp::stop("Error: Failed to create a command commands!");
  }
  
  SEXP result = CreateStreamsGpu(creatorInitialGlobalR, streamsMat, onGpu, keepInitial, context, commands, device);
  
  clReleaseCommandQueue(commands);
  clReleaseContext(context);
  
  return result;
}

//[[Rcpp::export]]
SEXP CreateStreamsBackend(
    Rcpp::IntegerVector creatorInitialGlobalR,
    Rcpp::S4 streamsR,
    Rcpp::IntegerMatrix streamsMat,
    const int onGpu,
    const int keepInitial) {
  
  colnames(streamsMat) = Rcpp::CharacterVector::create(
    "current.g1.1", "current.g1.2", "current.g1.3", "current.g2.1", "current.g2.2", "current.g2.3",
    "initial.g1.1", "initial.g1.2", "initial.g1.3", "initial.g2.1", "initial.g2.2", "initial.g2.3");
  
  return CreateStreamsTemplated(creatorInitialGlobalR, streamsR, streamsMat, onGpu, keepInitial);
}
