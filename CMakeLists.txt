cmake_minimum_required(VERSION 3.10)
project(Tensorflow)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)


set(TF_SCRPT ${PROJECT_SOURCE_DIR}/tensorflow/bin)

#------------------------Setting scripts and main paths
set(TF_PREPARE_SCRIPT "${TF_SCRPT}/prepare.sh")
set(TF_BUILD_SCRIPT "${TF_SCRPT}/build.sh")

set(TF_SRC "${PROJECT_BINARY_DIR}/tensorflow_src")
set(TF_LIB "${PROJECT_BINARY_DIR}/tensorflow_lib")
#------------------------Setting main variables

set(ENV{TF_SRC} "${TF_SRC}")
set(ENV{TF_LIB} "${TF_LIB}")


#------------------------Setting options for configure file

#OPTION(TF_NEED_OPENCL_SYCL "In case you want to compile Tensorflow with openCL support" OFF)
OPTION(TF_NEED_CUDA "In case you want to compile Tensorflow with CUDA support" ON)


set(PYTHON_BIN_PATH "/usr/bin/python3" CACHE STRING "Set path to python binary. 3x version is preferable")
set(PYTHON_LIB_PATH "/usr/local/lib/python3.6/dist-packages" CACHE STRING "Set path to python dist-packages")


if (TF_NEED_CUDA)

    set(TF_CUDA_VERSION "10.2" CACHE STRING "Set Cuda version for GPU build")
    set(CUDA_TOOLKIT_PATH "/usr/local/cuda" CACHE STRING "Set path to cuda toolkit")
    set(CUDNN_INSTALL_PATH "/usr/lib/x86_64-linux-gnu" CACHE STRING "Set path to cudnn")
    set(CUDA_COMPUTE_CAPABILITIES "5.0,6.1,7.0,7.2,7,5 " CACHE STRING "Set compute capabilities that need to be supported")

    OPTION(TF_NEED_TENSORRT "In case you want to compile Tensorflow with TensorRT support" ON)
    OPTION(TF_CUDA_CLANG "In case you need to use Clang as CUDA compiler" OFF)

    if (TF_CUDA_CLANG)
        set(CLANG_COMPILER_PATH "/usr/bin/clang" CACHE STRING "Set path to clang compiler")
    else ()
        set(GCC_HOST_COMPILER_PATH "/usr/bin/gcc" CACHE STRING "Set path to gcc compiler")
    endif ()
endif ()

execute_process(COMMAND ${TF_PREPARE_SCRIPT})


configure_file(${CMAKE_CURRENT_SOURCE_DIR}/tensorflow/bin/tf_configure.bazelrc.in ${TF_SRC}/.tf_configure.bazelrc)

add_custom_target(TensorflowLIB ALL
        #        COMMAND /bin/sh ${TF_SRC}/configure
#        COMMAND ${CMAKE_COMMAND} -E env " TF_LIB=${TF_LIB}" "TF_SRC=${TF_SRC}" /bin/sh ${TF_PREPARE_SCRIPT}
        COMMAND echo "Start building TENSORFLOW"
        COMMAND ${CMAKE_COMMAND} -E env "TF_LIB=${TF_LIB}" "TF_SRC=${TF_SRC}" "TF_SCRPT=${TF_SCRPT}" /bin/sh ${TF_BUILD_SCRIPT}
        )

#==
# Installation part
#==

set(TENSORFLOW_ROOT ${TF_LIB})

set(TENSORFLOW_VERSION "Custom")
set(TENSORFLOW_SRC_DIR ${TENSORFLOW_ROOT})

# Step 2: Determine if to include headers and libraries in-source or via the installation path
if (TF_USE_IN_SOURCE)
  set(TENSORFLOW_INSTALL_DIR ${TENSORFLOW_SRC_DIR})
else()
  set(TENSORFLOW_INSTALL_DIR ${CMAKE_INSTALL_PREFIX})
endif()

#==
# Build target
#==

# Collect a list of header directories
file(GLOB TENSORFLOW_HDRS RELATIVE ${TENSORFLOW_SRC_DIR}/include ${TENSORFLOW_SRC_DIR}/include/*)
foreach(subdir ${TENSORFLOW_HDRS})
  list(APPEND TENSORFLOW_SRC_HEADERS ${TENSORFLOW_SRC_DIR}/include/${subdir})
  list(APPEND TENSORFLOW_HEADERS ${TENSORFLOW_INSTALL_DIR}/include/${subdir})
endforeach()
list(APPEND TENSORFLOW_SRC_HEADERS ${TENSORFLOW_SRC_DIR}/include/bazel-genfiles)
list(APPEND TENSORFLOW_HEADERS ${TENSORFLOW_INSTALL_DIR}/include/bazel-genfiles)

# Collect a list of library binaries
FILE(GLOB TENSORFLOW_LIBS RELATIVE ${TENSORFLOW_SRC_DIR}/lib ${TENSORFLOW_SRC_DIR}/lib/*)
foreach(lib ${TENSORFLOW_LIBS})
  list(APPEND TENSORFLOW_SRC_LIBRARIES ${TENSORFLOW_SRC_DIR}/lib/${lib})
  list(APPEND TENSORFLOW_LIBRARIES ${TENSORFLOW_INSTALL_DIR}/lib/${lib})
endforeach()

# Define interface target
add_library(${PROJECT_NAME} INTERFACE)
target_include_directories(${PROJECT_NAME}
  INTERFACE
    $<BUILD_INTERFACE:${TENSORFLOW_SRC_DIR}/include>
    $<BUILD_INTERFACE:${TENSORFLOW_SRC_DIR}/include/bazel-genfiles>
    "$<BUILD_INTERFACE:${EIGEN3_INCLUDE_DIRS}>"
    $<INSTALL_INTERFACE:$<INSTALL_PREFIX>/include>
    $<INSTALL_INTERFACE:$<INSTALL_PREFIX>/include/bazel-genfiles>
    "$<INSTALL_INTERFACE:${EIGEN3_INCLUDE_DIRS}>"
)
target_link_libraries(${PROJECT_NAME} INTERFACE ${TENSORFLOW_LIBRARIES})
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

#==
# Package targets
#==

install(TARGETS ${PROJECT_NAME}
  EXPORT ${PROJECT_NAME}-targets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)

export(TARGETS ${PROJECT_NAME}
  NAMESPACE ${PROJECT_NAME}::
  FILE ${PROJECT_NAME}-targets.cmake
)

install(EXPORT ${PROJECT_NAME}-targets
  FILE ${PROJECT_NAME}-targets.cmake
  NAMESPACE ${PROJECT_NAME}::
  DESTINATION ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}/cmake
)

#==
# Package configuration
#==

# Set package configurations
set(CONFIG_VERSION ${TENSORFLOW_VERSION})
set(CONFIG_DIRECTORY ${TENSORFLOW_INSTALL_DIR})

# Generate package configuration file
configure_package_config_file(
  ${CMAKE_CURRENT_LIST_DIR}/tensorflow/cmake/tensorflow-config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/tensorflow/cmake/tensorflow-config.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}/cmake
)

# Generate package version file
write_basic_package_version_file(tensorflow/cmake/tensorflow-config-version.cmake
  VERSION ${TENSORFLOW_VERSION}
  COMPATIBILITY AnyNewerVersion
)

#==
# Package installation
#==

# Install package configuration files
install(
  FILES
    ${CMAKE_CURRENT_BINARY_DIR}/tensorflow/cmake/tensorflow-config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/tensorflow/cmake/tensorflow-config-version.cmake
  DESTINATION
    ${CMAKE_INSTALL_DATADIR}/${PROJECT_NAME}/cmake
)

# Install the library (i.e. headers and libraries) if not used in-source
if (NOT TF_USE_IN_SOURCE)
  install(
    DIRECTORY
      ${TENSORFLOW_SRC_HEADERS}
    DESTINATION
      ${CMAKE_INSTALL_INCLUDEDIR}
  )
  install(
    FILES
      ${TENSORFLOW_SRC_LIBRARIES}
    DESTINATION
      ${CMAKE_INSTALL_LIBDIR}
  )
endif ()
