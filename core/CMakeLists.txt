# vxl/CMakeLists.txt

project( vxlcore )

doxygen_add_book(core "VXL overview documentation")

doxygen_add_package(core "Core Vision Libraries")
doxygen_add_package(core-L2 "Level-2 Vision Libraries")
doxygen_add_package(core-L2E "Level-2 Vision Libraries (Experimental)")
doxygen_add_package(core-test "Test Framework")


set(global_sources
 vxl_copyright.h
 vxl_version.h
)
# If VXL_INSTALL_INCLUDE_DIR is the default value
if("${VXL_INSTALL_INCLUDE_DIR}" STREQUAL "include/vxl")
  set(prefix "${VXL_INSTALL_INCLUDE_DIR}/core")
else()
  set(prefix "${VXL_INSTALL_INCLUDE_DIR}")
endif()
INSTALL_NOBASE_HEADER_FILES(${prefix} ${global_sources})

#
# Do platform-specific configuration.
# configure files
#
vxl_configure_file(${CMAKE_CURRENT_LIST_DIR}/vxl_config.h.in ${PROJECT_BINARY_DIR}/vxl_config.h ${prefix})
include_directories(${PROJECT_BINARY_DIR})

# numerics
if(VXL_BUILD_CORE_NUMERICS)
  add_subdirectory(vnl)
endif()


# common test executable
add_subdirectory(testlib)

# Tests that check and output the vxl configuration
# NOTE: some external projects remove the tests directory (aka ITK)
if( BUILD_TESTING AND EXISTS "tests")
  add_subdirectory(tests)
endif()
