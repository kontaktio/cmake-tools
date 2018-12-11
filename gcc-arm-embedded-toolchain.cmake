# This is a toolchain file meant for CMake cross-compilation for Cortex M architectures.
#
# REQUIREMENTS
# Environment variable EST_ROOT must be defined, pointing to directory containing installed gcc
# compilers.
#
# USAGE
# Invoke cmake like (example provided for .bat script):
#    cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug^
#    -DCMAKE_TOOLCHAIN_FILE=%EST_ROOT%\cmake-toolchains\gcc-arm-embedded-toolchain.cmake^
#    -DGCC_VERSION=gcc-arm-none-eabi-4.9-2014q4^
#    -DCMAKE_SYSTEM_PROCESSOR=cortex-m0
#
# Supported processors: cortex-m0, cortex-m3, cortex-m4
#

message(STATUS "Processing toolchain file ${CMAKE_CURRENT_LIST_FILE}")
file(TO_CMAKE_PATH "$ENV{EST_ROOT}" EST_ROOT)

# Create list of available gcc-none-eabi compiler versions
file(GLOB GCC_COMPILERS_AVAILABLE "${EST_ROOT}/gcc-arm-none-eabi-*")
string(REGEX REPLACE ";" "\n    " GCC_COMPILERS_AVAILABLE ";${GCC_COMPILERS_AVAILABLE};")

#initialize variables from environment
set(CMTOOLS_SYSTEM_PROCESSOR $ENV{CMTOOLS_SYSTEM_PROCESSOR})
set(GCC_VERSION $ENV{CMTOOLS_GCC_VERSION})

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

# CMTOOLS_SYSTEM_PROCESSOR should be provided on command line
if(DEFINED CMAKE_SYSTEM_PROCESSOR)
    message(WARNING "Variable CMAKE_SYSTEM_PROCESSOR is deprecated! Use CMTOOLS_SYSTEM_PROCESSOR instead!")
    set(CMTOOLS_SYSTEM_PROCESSOR ${CMAKE_SYSTEM_PROCESSOR})
    unset(CMAKE_SYSTEM_PROCESSOR)
endif()

if(DEFINED CMTOOLS_SYSTEM_PROCESSOR AND CMTOOLS_SYSTEM_PROCESSOR)
    message(STATUS "Generating buildsystem for ${CMTOOLS_SYSTEM_PROCESSOR}")
else()
    message(STATUS "Generating mutlitarget buildsystem")
endif()

file(TO_CMAKE_PATH "${EST_ROOT}/${GCC_VERSION}" EST_ROOT)

# Create prefix for gnu toolchain executables
set(GCC_PREFIX "$ENV{EST_ROOT}/${GCC_VERSION}/bin/arm-none-eabi-")
get_filename_component(GCC_PREFIX
  "${GCC_PREFIX}" REALPATH
)
# Create system-dependant extension
if(WIN32)
    set(EXE ".exe")
else()
    set(EXE "")
endif()
# Create CMAKE_AR variable as CMAKE doesn't do this properly
set(CMAKE_AR ${GCC_PREFIX}ar${EXE} CACHE FILEPATH "Archiver")

# Create variables pointing to toolchain tools
set(GCC_SIZE ${GCC_PREFIX}size${EXE} CACHE FILEPATH "Size printer")
set(GCC_OBJCOPY ${GCC_PREFIX}objcopy${EXE} CACHE FILEPATH "Object copy tool")
set(GCC_OBJDUMP ${GCC_PREFIX}objdump${EXE} CACHE FILEPATH "Object dump tool")
set(GCC_NM ${GCC_PREFIX}nm${EXE} CACHE FILEPATH "NM tool")

message(STATUS "Cross-compiling with the gcc-arm-embedded toolchain")
if(DEFINED CMTOOLS_SYSTEM_PROCESSOR AND "${CMTOOLS_SYSTEM_PROCESSOR}")
  message(STATUS "Target processor: ${CMTOOLS_SYSTEM_PROCESSOR}")
endif()
message(STATUS "GCC toolchain prefix: ${GCC_PREFIX}")

include(CMakeForceCompiler)

set(CMAKE_SYSTEM_NAME Generic) # Targeting an embedded system, no OS.
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

if(CMAKE_VERSION VERSION_LESS 3.6)
    CMAKE_FORCE_C_COMPILER(${GCC_PREFIX}gcc${EXE} GNU)
    CMAKE_FORCE_CXX_COMPILER(${GCC_PREFIX}g++${EXE} GNU)
else()
    set(CMAKE_C_COMPILER ${GCC_PREFIX}gcc${EXE})
    set(CMAKE_CXX_COMPILER ${GCC_PREFIX}g++${EXE})
endif()

set(CMAKE_FIND_ROOT_PATH  "${EST_ROOT}/${GCC_VERSION}/bin/")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)


# Create mandatory flags for processor, toolchain etc.
set(TOOLCHAIN_COMMON_FLAGS "-ffunction-sections -fdata-sections")

set(CORTEX_M0_FLAGS -mcpu=cortex-m0 -mthumb -mabi=aapcs -mfloat-abi=soft)
set(CORTEX_M3_FLAGS -mcpu=cortex-m3 -mthumb -mabi=aapcs -mfloat-abi=soft)
set(CORTEX_M4_FLAGS -mcpu=cortex-m4 -mthumb -mabi=aapcs -mfloat-abi=hard -mfpu=fpv4-sp-d16)

if(DEFINED CMTOOLS_SYSTEM_PROCESSOR AND CMTOOLS_SYSTEM_PROCESSOR)
  if(CMTOOLS_SYSTEM_PROCESSOR STREQUAL "cortex-m3")
    string (REPLACE ";" " " FLAGS "${CORTEX_M3_FLAGS}")
    set(TOOLCHAIN_COMMON_FLAGS
      "${TOOLCHAIN_COMMON_FLAGS} ${FLAGS}"
    )
  elseif(CMTOOLS_SYSTEM_PROCESSOR STREQUAL "cortex-m0")
    string (REPLACE ";" " " FLAGS "${CORTEX_M0_FLAGS}")
    set(TOOLCHAIN_COMMON_FLAGS
      "${TOOLCHAIN_COMMON_FLAGS} ${FLAGS}"
    )
  elseif(CMTOOLS_SYSTEM_PROCESSOR STREQUAL "cortex-m4")
    string (REPLACE ";" " " FLAGS "${CORTEX_M4_FLAGS}")
    set(TOOLCHAIN_COMMON_FLAGS
      "${TOOLCHAIN_COMMON_FLAGS} $${FLAGS}>"
    )
  else()
    message(WARNING
      "Processor not recognised in toolchain file, "
      "compiler flags not configured."
    )
  endif()
  message(STATUS "Toolchain flags set to: ${TOOLCHAIN_COMMON_FLAGS} , ${FLAGS}")
else()
  message(WARNING "Please set the CMTOOL_SYSTEM_PROCESSOR variable, else the compilation will fail")
endif()

set(CMAKE_C_FLAGS "${TOOLCHAIN_COMMON_FLAGS}" CACHE INTERNAL "")
set(CMAKE_CXX_FLAGS "${TOOLCHAIN_COMMON_FLAGS}" CACHE INTERNAL "")
set(CMAKE_EXE_LINKER_FLAGS  "-Wl,--gc-sections --specs=nano.specs" CACHE INTERNAL "")

set(ENV{CMTOOLS_GCC_VERSION} "${GCC_VERSION}")
set(ENV{CMTOOLS_SYSTEM_PROCESSOR} "${CMTOOLS_SYSTEM_PROCESSOR}")
