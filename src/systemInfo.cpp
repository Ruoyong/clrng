#include <Rcpp.h>
#include <iostream>

#ifdef __APPLE__
#include <sys/types.h>
#include <sys/sysctl.h>
#elif __linux__
#include <fstream>
#include <sstream>
#elif _WIN32
#include <windows.h>
#endif

#ifdef __APPLE__
#include <OpenCL/opencl.h>
#else
#include <CL/cl.h>
#endif

// Function to get operating system name
std::string getOSName() {
#ifdef _WIN32
  return "Windows";
#elif __APPLE__ || __MACH__
  return "macOS";
#elif __linux__
  return "Linux";
#elif __FreeBSD__
  return "FreeBSD";
#else
  return "Other";
#endif
}

// Function to get CPU information
std::string getCPUInfo() {
  std::string cpuInfo = "Unknown";
#ifdef __APPLE__
  char cpuBrand[256];
  size_t size = sizeof(cpuBrand);
  if (sysctlbyname("machdep.cpu.brand_string", &cpuBrand, &size, NULL, 0) == 0) {
    cpuInfo = cpuBrand;
  }
#elif __linux__
  std::ifstream cpuinfo("/proc/cpuinfo");
  std::string line;
  while (std::getline(cpuinfo, line)) {
    if (line.substr(0, 10) == "model name") {
      size_t pos = line.find(":");
      if (pos != std::string::npos) {
        cpuInfo = line.substr(pos + 2);
        break;
      }
    }
  }
#elif _WIN32
  HKEY hKey;
  if (RegOpenKeyEx(HKEY_LOCAL_MACHINE, "HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0", 0, KEY_READ, &hKey) == ERROR_SUCCESS) {
    char value[256];
    DWORD size = sizeof(value);
    if (RegQueryValueEx(hKey, "ProcessorNameString", NULL, NULL, (LPBYTE)&value, &size) == ERROR_SUCCESS) {
      cpuInfo = value;
    }
    RegCloseKey(hKey);
  }
#endif
  return cpuInfo;
}

// Function to get GPU information
std::string getGPUInfo() {
  std::string gpuInfo = "Not detected";
  
  cl_platform_id platform;
  cl_device_id device;
  cl_uint numPlatforms;
  cl_uint numDevices;
  
  clGetPlatformIDs(1, &platform, &numPlatforms);
  clGetDeviceIDs(platform, CL_DEVICE_TYPE_GPU, 1, &device, &numDevices);
  
  if (numDevices > 0) {
    char deviceName[256];
    clGetDeviceInfo(device, CL_DEVICE_NAME, sizeof(deviceName), &deviceName, NULL);
    gpuInfo = deviceName;
  }
  
  return gpuInfo;
}

// Function to print system information
// [[Rcpp::export]]
void printSystemInfo() {
  // Operating System Information
  std::cout << "Operating System: " << getOSName() << std::endl;
  
  // CPU Information
  std::cout << "CPU: " << getCPUInfo() << std::endl;
  
  // GPU Information
  std::cout << "GPU: " << getGPUInfo() << std::endl;
  
  // OpenCL Version Information
  char version[256];
  clGetPlatformInfo(NULL, CL_PLATFORM_VERSION, sizeof(version), &version, NULL);
  std::cout << "OpenCL Version: " << version << std::endl;
}

// Expose the function to R
RcppExport SEXP _printSystemInfo() {
  printSystemInfo();
  return Rcpp::wrap(1L);
}


