# vcl/CMakeLists.txt
#
# vcl is now header-only: it provides the configured vcl_compiler.h /
# vcl_where_root_dir.h and the vcl_msvc_warnings.h shim. The include
# directories are propagated globally from the top-level CMakeLists, so
# no library target is built and consumers do not link anything for vcl.

project( vcl )

# If VXL_INSTALL_INCLUDE_DIR is the default value
if("${VXL_INSTALL_INCLUDE_DIR}" STREQUAL "include/vxl")
  set(_config_destination ${VXL_INSTALL_INCLUDE_DIR}/vcl)
else()
  set(_config_destination ${VXL_INSTALL_INCLUDE_DIR})
endif()
vxl_configure_file(${CMAKE_CURRENT_LIST_DIR}/vcl_compiler.h.in ${PROJECT_BINARY_DIR}/vcl_compiler.h ${_config_destination})
vxl_configure_file(${CMAKE_CURRENT_LIST_DIR}/vcl_where_root_dir.h.in ${PROJECT_BINARY_DIR}/vcl_where_root_dir.h  ${_config_destination})

install(FILES vcl_msvc_warnings.h
    DESTINATION ${_config_destination}
    PERMISSIONS OWNER_WRITE OWNER_READ GROUP_READ WORLD_READ
    COMPONENT Development )

if( BUILD_TESTING)
  add_subdirectory(tests)
endif()
