#
# This is a toolchain file meant for use with CMake cross-compilation for Cortex M architectures.
#
# USAGE
# Invoke cmake like (example provided for .bat script):
#    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug^
#    -DCMAKE_TOOLCHAIN_FILE=%EST_ROOT%\cmake-toolchains\gcc-arm-embedded.cmake^
#    -DGCC_VERSION=gcc-arm-none-eabi-4.9-2014q4
#    -DCMAKE_SYSTEM_PROCESSOR=cortex-m4
#
# Supported processors: cortex-m0, cortex-m3, cortex-m4
#
# REQUIREMENTS
# Environment variable EST_ROOT must be defined, pointing to directory containing installed gcc 
# compilers.
#

file(TO_CMAKE_PATH "$ENV{EST_ROOT}" EST_ROOT)

# Create list of available gcc-none-eabi compiler versions
file(GLOB GCC_COMPILERS_AVAILABLE "${EST_ROOT}/gcc-arm-none-eabi-*")
string(REGEX REPLACE ";" "\n    " GCC_COMPILERS_AVAILABLE ";${GCC_COMPILERS_AVAILABLE};")

# GCC_VERSION should be provided on command line
if(NOT DEFINED GCC_VERSION)
    message(FATAL_ERROR
        "GCC_VERSION not defined. Available gcc versions in EST:"
        "${GCC_COMPILERS_AVAILABLE}"
    )
elseif(NOT IS_DIRECTORY ${EST_ROOT}/${GCC_VERSION})
    message(FATAL_ERROR
        "Directory ${EST_ROOT}/${GCC_VERSION} does not exist. Available gcc versions in EST:"
        "    ${GCC_COMPILERS_AVAILABLE}"
    )
else()
    message(STATUS "Generating buildsystem using ${GCC_VERSION}")
endif()

# CMAKE_SYSTEM_PROCESSOR should be provided on command line
if(NOT DEFINED CMAKE_SYSTEM_PROCESSOR)
    message(SEND_ERROR "CMAKE_SYSTEM_PROCESSOR not defined")
else()
    message(STATUS "Compiling for ${CMAKE_SYSTEM_PROCESSOR}")
endif()

file(TO_CMAKE_PATH "${EST_ROOT}/${GCC_VERSION}" EST_ROOT)

# Create prefix for gnu toolchain executables
set(GCC_PREFIX "$ENV{EST_ROOT}/${GCC_VERSION}/bin/arm-none-eabi-")
get_filename_component(GCC_PREFIX
  "${GCC_PREFIX}" REALPATH
)

# Create CMAKE_AR variable as CMAKE doesn't do this properly
set(CMAKE_AR ${GCC_PREFIX}ar.exe CACHE FILEPATH "Archiver")

# Create variables pointing to toolchain tools
set(GCC_SIZE ${GCC_PREFIX}size.exe CACHE FILEPATH "Size printer")
set(GCC_OBJCOPY ${GCC_PREFIX}objcopy.exe CACHE FILEPATH "Object copy tool")
set(GCC_OBJDUMP ${GCC_PREFIX}objdump.exe CACHE FILEPATH "Object dump tool")
set(GCC_NM ${GCC_PREFIX}nm.exe CACHE FILEPATH "NM tool")

message(STATUS "Cross-compiling with the gcc-arm-embedded toolchain")
message(STATUS "Target processor: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "GCC toolchain prefix: ${GCC_PREFIX}")

include(CMakeForceCompiler)

set(CMAKE_SYSTEM_NAME Generic) # Targeting an embedded system, no OS.

CMAKE_FORCE_C_COMPILER(${GCC_PREFIX}gcc.exe GNU)
CMAKE_FORCE_CXX_COMPILER(${GCC_PREFIX}g++.exe GNU)

set(CMAKE_FIND_ROOT_PATH  "${EST_ROOT}/${GCC_VERSION}/bin/")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY


# Create mandatory flags for processor, toolchain etc.
set(TOOLCHAIN_COMMON_FLAGS "-ffunction-sections -fdata-sections")

if(CMAKE_SYSTEM_PROCESSOR STREQUAL "cortex-m4")
  set(TOOLCHAIN_COMMON_FLAGS
    "${TOOLCHAIN_COMMON_FLAGS} -mcpu=cortex-m4 -mthumb -mfloat-abi=hard -mfpu=fpv4-sp-d16"
  )
elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "cortex-m3")
  set(TOOLCHAIN_COMMON_FLAGS
    "${TOOLCHAIN_COMMON_FLAGS} -mcpu=cortex-m3 -mthumb"
  )
elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "cortex-m0")
  set(TOOLCHAIN_COMMON_FLAGS
    "${TOOLCHAIN_COMMON_FLAGS} -mcpu=cortex-m0 -mthumb"
  )
else()
  message(WARNING
    "Processor not recognised in toolchain file, "
    "compiler flags not configured."
  )
endif()

set(CMAKE_C_FLAGS "${TOOLCHAIN_COMMON_FLAGS}")
set(CMAKE_CXX_FLAGS "${TOOLCHAIN_COMMON_FLAGS}")
