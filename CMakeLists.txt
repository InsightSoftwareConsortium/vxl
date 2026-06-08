# Root vxl

cmake_minimum_required(VERSION 3.22.1...3.31.9)

# Normalize a two-digit C/C++ standard token to its ISO release year so
# ordering survives the C99(1999)/C11(2011) two-digit wraparound.
function(vxl_standard_release_year _token _result)
  if(_token LESS_EQUAL 50)
    math(EXPR _year "2000 + ${_token}")
  else()
    math(EXPR _year "1900 + ${_token}")
  endif()
  set(${_result} "${_year}" PARENT_SCOPE)
endfunction()

if(NOT CMAKE_CXX_STANDARD)
   set(CMAKE_CXX_STANDARD "17")
endif()
if(NOT CMAKE_CXX_STANDARD_REQUIRED)
  set(CMAKE_CXX_STANDARD_REQUIRED ON)
endif()
if(NOT CMAKE_CXX_EXTENSIONS)
  set(CMAKE_CXX_EXTENSIONS OFF)
endif()
# VXL 7 requires C++17 (2017) or newer.
vxl_standard_release_year("${CMAKE_CXX_STANDARD}" VXL_CXX_STANDARD_YEAR)
if(VXL_CXX_STANDARD_YEAR LESS 2017)
   message(FATAL_ERROR "CMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD} (ISO ${VXL_CXX_STANDARD_YEAR}) is older than the required C++17 (2017) minimum.")
endif()

if(NOT CMAKE_C_STANDARD)
   set(CMAKE_C_STANDARD "11")
endif()
if(NOT CMAKE_C_STANDARD_REQUIRED)
  set(CMAKE_C_STANDARD_REQUIRED ON)
endif()
if(NOT CMAKE_C_EXTENSIONS)
  set(CMAKE_C_EXTENSIONS OFF)
endif()
# VXL 7 requires C11 (2011) or newer.
vxl_standard_release_year("${CMAKE_C_STANDARD}" VXL_C_STANDARD_YEAR)
if(VXL_C_STANDARD_YEAR LESS 2011)
   message(FATAL_ERROR "CMAKE_C_STANDARD:STRING=${CMAKE_C_STANDARD} (ISO ${VXL_C_STANDARD_YEAR}) is older than the required C11 (2011) minimum.")
endif()

project(VXL #Project name must be all caps to have properly generated VXL_VERSION_* variables
    VERSION 7.0.0.0 # defines #MAJOR,MINOR,PATCH,TWEAK}; major bump signals C++17 minimum
    DESCRIPTION "A multi-platform collection of C++ software libraries for Computer Vision and Image Understanding."
    LANGUAGES CXX C)

SET(VXL_API_VERSION "${VXL_VERSION_MAJOR}.${VXL_VERSION_MINOR}")
SET(VXL_LIBRARY_PROPERTIES ${VXL_LIBRARY_PROPERTIES} VERSION "${VXL_VERSION}"
    SOVERSION "${VXL_API_VERSION}")

include(CMakeDependentOption)

#Disable overzealous compiler warning.  If the definition is truely missing a link error will be created.
include(CheckCXXCompilerFlag)
include(CheckPIESupported)
check_pie_supported()

find_program( MEMORYCHECK_COMMAND valgrind )
if(MEMORYCHECK_COMMAND)
  set( MEMORYCHECK_COMMAND_OPTIONS "--trace-children=yes --leak-check=full --malloc-fill=0xFF" )
  set( MEMORYCHECK_SUPPRESSIONS_FILE "${CMAKE_CURRENT_LIST_DIR}/config/valgrind.supp" )
endif()

#-----------------------------------------------------------------------------
if(NOT COMMAND SETIFEMPTY)
  macro(SETIFEMPTY)
    set(KEY ${ARGV0})
    set(VALUE ${ARGV1})
    if(NOT ${KEY})
      set(${ARGV})
    endif()
  endmacro()
endif()

#-----------------------------------------------------------------------------
SETIFEMPTY(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
SETIFEMPTY(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
SETIFEMPTY(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

#-----------------------------------------------------------------------------
SETIFEMPTY(CMAKE_INSTALL_LIBRARY_DESTINATION lib)
SETIFEMPTY(CMAKE_INSTALL_ARCHIVE_DESTINATION lib)
SETIFEMPTY(CMAKE_INSTALL_RUNTIME_DESTINATION bin)

SETIFEMPTY(VXL_INSTALL_RUNTIME_DIR bin)
SETIFEMPTY(VXL_INSTALL_LIBRARY_DIR lib)
SETIFEMPTY(VXL_INSTALL_ARCHIVE_DIR lib)
SETIFEMPTY(VXL_INSTALL_INCLUDE_DIR include/vxl)
# Export-set name for install(TARGETS ... EXPORT ...). ITK overrides this
# to fold the vxl targets into its own export set; standalone builds use it
# as a local export set name (no standalone VXLConfig is generated).
SETIFEMPTY(VXL_INSTALL_EXPORT_NAME VXLTargets)

# CMake support directory.
set(VXL_ROOT_SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR})
set(VXL_CMAKE_DIR ${CMAKE_CURRENT_LIST_DIR}/config/cmake/Modules)

include( ${VXL_CMAKE_DIR}/VXLStandardOptions.cmake )
include( GenerateExportHeader )
include( ${CMAKE_CURRENT_LIST_DIR}/config/cmake/config/vxl_utils.cmake )
# set the vxl_platform_math target
include(${CMAKE_CURRENT_LIST_DIR}/config/cmake/Modules/ConfigurePlatformMathTarget.cmake)


if(MSVC)
  # Force synchronous writes of .pdb files (/FS) to avoid PDB contention.
  add_compile_options( "/FS" )
endif()
#-------------------------------------------------------------------
#-- BUILD CONFIG OPTIONS

# Optionally use old error reporting methods, rather than exceptions.
# The main use is in vil which often uses/used null images to imply an error.
option(VXL_RUN_FAILING_TESTS "Enable long-time failing tests. If tests are failing for a long time, turn them off by default." OFF)
mark_as_advanced(VXL_RUN_FAILING_TESTS)

# Build position-independent code so the static vxl libraries can be linked
# into shared libraries (as ITK does). CMake emits the correct per-compiler
# flag across platforms.
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Standard include directories.
set(VXLCORE_INCLUDE_DIR ${CMAKE_CURRENT_LIST_DIR}/core)    #Source includes
set(VXLCORE_BINARY_INCLUDE_DIR ${PROJECT_BINARY_DIR}/core) #Generated includes
set(VXLCORE_INCLUDE_DIRS ${VXLCORE_BINARY_INCLUDE_DIR} ${VXLCORE_INCLUDE_DIR})
set(VXLCORE_INSTALL_INCLUDE_DIR ${CMAKE_INSTALL_PREFIX}/include/vxl/core)

set(VCL_INCLUDE_DIR ${CMAKE_CURRENT_LIST_DIR}/vcl)    #Source includes
set(VCL_BINARY_INCLUDE_DIR ${PROJECT_BINARY_DIR}/vcl) #Generated includes
set(VCL_INCLUDE_DIRS ${VCL_BINARY_INCLUDE_DIR} ${VCL_INCLUDE_DIR})
set(VCL_INSTALL_INCLUDE_DIR ${CMAKE_INSTALL_PREFIX}/include/vxl/vcl)

include_directories(${VCL_INCLUDE_DIRS} ${VXLCORE_INCLUDE_DIRS})

# Do platform-specific configuration.
include(${CMAKE_CURRENT_LIST_DIR}/config/cmake/config/VXLIntrospectionConfig.cmake)


#-------------------------------------------------------------------
#-- BUILD SELECTION OPTIONS
# Options for selecting the core core libraries
option( VXL_BUILD_CORE_NUMERICS "Build VXL's numerics libraries" ON )

# Build the core vxl + support libraries
add_subdirectory(vcl)
add_subdirectory(v3p)
add_subdirectory(core)

# Copy CTestCustom.cmake to top of build tree
configure_file( ${VXL_CMAKE_DIR}/CTestCustom.cmake
  ${VXL_BINARY_DIR}/CTestCustom.cmake COPYONLY )
