# Toolchain-dependent configuration values.
#
# The platform-introspection probes (SSE2, integer/IEEE type sizes, byte
# order, unistd/library quirks, ...) have all been retired: those values
# are now resolved at compile time in vxl_config.h. The only remaining
# configured value is the C++ standard level VXL was built with, recorded
# so external applications can check build compatibility.

# VXL_UPDATE_CONFIGURATION is retained because ITK forces it OFF when it
# embeds this tree; it is reset to OFF after each configure.
option( VXL_UPDATE_CONFIGURATION "Re-run the configuration tests to update cached results?" "OFF" )
mark_as_advanced( VXL_UPDATE_CONFIGURATION )
set( VXL_UPDATE_CONFIGURATION "OFF" CACHE BOOL "Re-run the configuration tests?" FORCE )

if(CMAKE_CXX_STANDARD)
  set(TRY_COMP_CXX_STANDARD -DCMAKE_CXX_STANDARD:STRING=${CMAKE_CXX_STANDARD})
endif()
# Identify the version of CXX compiler used when VXL was built. This needs to be
# identified so that external applications can identify how VXL was built.
set(VXL_COMPILED_CXX_STANDARD_VERSION 201103L) # Minimum supported CXX_STANDARD version is 201103L
foreach(CXX_TEST_VERSION 201103L 201402L 201703L)
  try_compile(VXL_MIN_CXX_LEVEL_TEST
    ${CMAKE_CURRENT_BINARY_DIR}/CMakeTmp
    ${CMAKE_CURRENT_LIST_DIR}/vxlGetCXXCompilerVersion.cxx
    CMAKE_FLAGS
        -DCOMPILE_DEFINITIONS:STRING=${CMAKE_REQUIRED_FLAGS}
        ${TRY_COMP_CXX_STANDARD}
    COMPILE_DEFINITIONS -DVXL_CXX_TEST_VERSION=${CXX_TEST_VERSION}
    OUTPUT_VARIABLE VXL_COMPILED_CXX_STANDARD_VERSION_LOG
  )
  if(VXL_MIN_CXX_LEVEL_TEST)
     set(VXL_COMPILED_CXX_STANDARD_VERSION ${CXX_TEST_VERSION})
  endif()
endforeach()
