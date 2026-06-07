# vxl/vnl/xio/CMakeLists.txt

set(vnl_xio_sources
  vnl_xio_matrix_fixed.hxx   vnl_xio_matrix_fixed.h
  vnl_xio_matrix.hxx         vnl_xio_matrix.h
  vnl_xio_vector_fixed.hxx   vnl_xio_vector_fixed.h
  vnl_xio_vector.hxx         vnl_xio_vector.h
  vnl_xio_quaternion.hxx     vnl_xio_quaternion.h
)

aux_source_directory(Templates vnl_xio_sources)

vxl_add_library(LIBRARY_NAME itkvnl_xio
  LIBRARY_SOURCES ${vnl_xio_sources}
  HEADER_INSTALL_DIR vnl/xio)
target_link_libraries(itkvnl_xio itkvnl itkvsl)

if(BUILD_TESTING)
  add_subdirectory(tests)
endif()

if (VXL_BUILD_OBJECT_LIBRARIES)
  add_library(vnl_xio-obj OBJECT ${vnl_xio_sources})
endif()
