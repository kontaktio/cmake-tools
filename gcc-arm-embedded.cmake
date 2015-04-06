include(CMakeForceCompiler)

file(TO_CMAKE_PATH "$ENV{EST_ROOT}" EST_ROOT)

# Targeting an embedded system, no OS.
set(CMAKE_SYSTEM_NAME Generic)

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

CMAKE_FORCE_C_COMPILER(${GCC_PREFIX}gcc.exe GNU)
CMAKE_FORCE_CXX_COMPILER(${GCC_PREFIX}g++.exe GNU)

set(CMAKE_AR ${GCC_PREFIX}ar.exe CACHE FILEPATH "Archiver")
set(GCC_SIZE ${GCC_PREFIX}size.exe CACHE FILEPATH "Size printer")
set(GCC_OBJCOPY ${GCC_PREFIX}objcopy.exe CACHE FILEPATH "Object copy tool")
set(GCC_OBJDUMP ${GCC_PREFIX}objdump.exe CACHE FILEPATH "Object dump tool")

message(STATUS "Cross-compiling with the gcc-arm-embedded toolchain")
message(STATUS "Target processor: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "GCC toolchain prefix: ${GCC_PREFIX}")

set(CMAKE_FIND_ROOT_PATH  "${EST_ROOT}/${GCC_VERSION}/bin/")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

set(TOOLCHAIN_COMMON_FLAGS "-ffunction-sections -fdata-sections")

if(CMAKE_SYSTEM_PROCESSOR STREQUAL "cortex-m4")
  set(TOOLCHAIN_COMMON_FLAGS
    "${TOOLCHAIN_COMMON_FLAGS}"
    "-mcpu=cortex-m4 -march=armv7e-m -mthumb"
    "-mfloat-abi=hard -mfpu=fpv4-sp-d16"
  )
elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "cortex-m3")
  set(TOOLCHAIN_COMMON_FLAGS
    "${TOOLCHAIN_COMMON_FLAGS}"
    "-mcpu=cortex-m3 -march=armv7-m -mthumb"
    "-msoft-float"
  )
elseif(CMAKE_SYSTEM_PROCESSOR STREQUAL "cortex-m0")
  set(TOOLCHAIN_COMMON_FLAGS
    "${TOOLCHAIN_COMMON_FLAGS}"
    "-mcpu=cortex-m0 -march=armv7-m -mthumb"
    "-msoft-float"
  )
else()
  message(WARNING
    "Processor not recognised in toolchain file, "
    "compiler flags not configured."
  )
endif()

# When we break up long strings in CMake we get semicolon
# separated lists, undo this here...
string(REGEX REPLACE ";" " " TOOLCHAIN_COMMON_FLAGS "${TOOLCHAIN_COMMON_FLAGS}")
message(STATUS "Processor specific flags: ${TOOLCHAIN_COMMON_FLAGS}")

set(CMAKE_C_FLAGS "${TOOLCHAIN_COMMON_FLAGS}")
set(CMAKE_CXX_FLAGS "${TOOLCHAIN_COMMON_FLAGS}")

set(CMAKE_CROSS_COMPILING TRUE)
