cmake_minimum_required(VERSION 3.10)
project(TensorFlow)

include(GNUInstallDirs)
include(CMakePackageConfigHelpers)


set(TF_SCRPT ${PROJECT_SOURCE_DIR}/tensorflow/bin)

OPTION(WITH_PROTOBUF "Build and install protobuff" OFF)
OPTION(WITH_EIGEN "Build and install eigen" OFF)
OPTION(WITH_ABSEIL "Build and install Abseil" OFF)

OPTION(MKL_SUPPORT "Build with MKL support" OFF)
OPTION(MONOLITHIC "Config for mostly static monolithic build" OFF)
OPTION(GDR_SUPPORT "Build with libverbs support" OFF)
OPTION(NGRAPH_SUPPORT "Build with Intel nGraph support" OFF)
OPTION(NUMA_SUPPORT "Build with NUMA support" OFF)
OPTION(DYNAMIC_KERNELS "(Experimental) Build kernels into separate shared objects" OFF)
OPTION(CONFIG_V2 "Build TensorFlow 2.x instead of 1.x." OFF)


OPTION(XLA_SUPPORT "Build with XLA" OFF)
OPTION(AWS_SUPPORT "Build with AWS S3 filesystem support" OFF)
OPTION(IGNITE_SUPPORT "Build with Apache Ignite support" OFF)
OPTION(GCP_SUPPORT "Build with gcp support" OFF)
OPTION(HDFS_SUPPORT "Build with hdfs support" OFF)
OPTION(NCCL_SUPPORT "Build with nccl support" OFF)
OPTION(KAFKA_SUPPORT "Build with Apache Kafka support" OFF)


#==
# Setting scripts and main paths
#==

set(TF_PREPARE_SCRIPT "${TF_SCRPT}/prepare.sh")
set(TF_BUILD_SCRIPT "${TF_SCRPT}/build.sh")
set(PROTOBUF_SCRIPT "${PROJECT_SOURCE_DIR}/protobuf/build.sh")
set(ABSEIL_INIT_SCRIPT "${PROJECT_SOURCE_DIR}/abseil/build.sh")
set(EIGEN_SCRIPT "")


set(TF_SRC "${PROJECT_BINARY_DIR}/tensorflow_src")
set(TF_LIB "${PROJECT_BINARY_DIR}/tensorflow_lib")

#==
# Installing prerequisites
#==

if (WITH_PROTOBUF)
    execute_process(COMMAND ${PROTOBUF_SCRIPT})
endif ()

#if (WITH_EIGEN)
#    add_subdirectory(${PROJECT_SOURCE_DIR}/eigen)
#endif ()

#if (WITH_ABSEIL)
#    execute_process(COMMAND echo "Enabling abseil installation")
#    execute_process(COMMAND ${ABSEIL_INIT_SCRIPT})
#    add_subdirectory(${PROJECT_SOURCE_DIR}/abseil/abseil-cpp)
#endif ()

#==
# Setting main variables
#==

set(ENV{TF_SRC} "${TF_SRC}")
set(ENV{TF_LIB} "${TF_LIB}")

#==
# Setting options for configure file
#==

# Config build options

# Preconfigured Bazel build configs to DISABLE default on features
if (NOT AWS_SUPPORT)
    set(BUILD_AWS "build --config=noaws")
endif ()

if (NOT IGNITE_SUPPORT)
    set(BUILD_IGNITE "build --config=noignite")
endif ()

if (NOT GCP_SUPPORT)
    set(BUILD_GCP "build --config=nogcp")
endif ()

if (NOT HDFS_SUPPORT)
    set(BUILD_HDFS "build --config=nohdfs")
endif ()

if (NOT NCCL_SUPPORT)
    set(BUILD_NCCL "build --config=nonccl")
endif ()

if (NOT KAFKA_SUPPORT)
    set(BUILD_KAFKA "build --config=nokafka")
endif ()

# Preconfigured Bazel build configs.

if (XLA_SUPPORT)
    set(BUILD_XLA "build --config=xla")
    set(BUILD_XLA_SUPPORT "build:xla --define with_xla_support=true")
endif ()

if (MKL_SUPPORT)
    set(BUILD_MKL "build --config=mkl")
endif ()

if (MONOLITHIC)
    set(BUILD_MONOLITHIC "build --config=monolithic")
endif ()

if (GDR_SUPPORT)
    set(BUILD_GDR "build --config=gdr")
endif ()

if (NGRAPH_SUPPORT)
    set(BUILD_NGRAPH "build --config=ngraph")
endif ()

if (NUMA_SUPPORT)
    set(BUILD_NUMA "build --config=numa")
endif ()

if (DYNAMIC_KERNELS)
    set(BUILD_DYNAMIC_KERNELS "build --config=dynamic_kernels")
endif ()

if (CONFIG_V2)
    set(BUILD_CONFIG_V2 "build --config=v2")
endif ()


#OPTION(TF_NEED_OPENCL_SYCL "In case you want to compile Tensorflow with openCL support" OFF)
OPTION(TF_NEED_CUDA "In case you want to compile Tensorflow with CUDA support" OFF)


set(PYTHON_BIN_PATH "/usr/bin/python3" CACHE STRING "Set path to python binary. 3x version is preferable")
set(PYTHON_LIB_PATH "/usr/local/lib/python3.6/dist-packages" CACHE STRING "Set path to python dist-packages")


if (TF_NEED_CUDA)

    set(TF_NEED_CUDA_INT "1")
    set(TEST_CUDA "test --config=cuda")
    set(BUILD_CUDA "build --config=cuda")
    set(TF_CUDA_VERSION "10.2" CACHE STRING "Set Cuda version for GPU build")
    set(CUDA_TOOLKIT_PATH "/usr/local/cuda" CACHE STRING "Set path to cuda toolkit")
    set(CUDNN_INSTALL_PATH "/usr/lib/x86_64-linux-gnu" CACHE STRING "Set path to cudnn")
    set(CUDA_COMPUTE_CAPABILITIES "7.2,7.5" CACHE STRING "Set compute capabilities that need to be supported")

    OPTION(TF_NEED_TENSORRT "In case you want to compile Tensorflow with TensorRT support" OFF)
    if (TF_NEED_TENSORRT)
        set(TF_NEED_TENORRT_INT "1")
    else ()
        set(TF_NEED_TENSORRT_INT "0")
    endif ()
    OPTION(TF_CUDA_CLANG "In case you need to use Clang as CUDA compiler" OFF)

    if (TF_CUDA_CLANG)
        set(CLANG_COMPILER_PATH "/usr/bin/clang" CACHE STRING "Set path to clang compiler")
    else ()
        set(GCC_HOST_COMPILER_PATH "/usr/bin/gcc" CACHE STRING "Set path to gcc compiler")
    endif ()
else ()
    set(TF_NEED_CUDA_INT "0")
    set(TF_NEED_TENSORRT_INT "0")
endif ()

execute_process(COMMAND ${TF_PREPARE_SCRIPT})


configure_file(${CMAKE_CURRENT_SOURCE_DIR}/tensorflow/bin/tf_configure.bazelrc.in ${TF_SRC}/.tf_configure.bazelrc)

add_custom_target(TensorflowLIB
        #        COMMAND /bin/sh ${TF_SRC}/configure
        #        COMMAND ${CMAKE_COMMAND} -E env " TF_LIB=${TF_LIB}" "TF_SRC=${TF_SRC}" /bin/sh ${TF_PREPARE_SCRIPT}
        COMMAND echo "Start building TENSORFLOW"
        COMMAND ${CMAKE_COMMAND} -E env "TF_LIB=${TF_LIB}" "TF_SRC=${TF_SRC}" "TF_SCRPT=${TF_SCRPT}" /bin/sh ${TF_BUILD_SCRIPT}
        )

if (WITH_PROTOBUF)
    #    add_custom_target(Protobuf ALL
    #            COMMAND echo "Start building Protobuf"
    #            COMMAND ${CMAKE_COMMAND} /bin/sh ${PROTOBUF_SCRIPT}
    #            )
endif ()

if (WITH_ABSEIL)
    message("Abseil build has been enabled")
    #    add_custom_target(Abseil ALL
    #            COMMAND echo "Start building Abseil"
    #            COMMAND /bin/sh ${ABSEIL_INIT_SCRIPT}
    #            )
endif ()


#==
# Installation part
#==

set(TF_USE_IN_SOURCE OFF)
set(TENSORFLOW_ROOT ${TF_LIB})
message(TENSORFLOW_ROOT=${TENSORFLOW_ROOT})

set(TENSORFLOW_VERSION "Custom")
set(TENSORFLOW_SRC_DIR ${TENSORFLOW_ROOT})

# Determine if to include headers and libraries in-source or via the installation path
if (TF_USE_IN_SOURCE)
    set(TENSORFLOW_INSTALL_DIR ${TENSORFLOW_SRC_DIR})
else ()
    set(TENSORFLOW_INSTALL_DIR ${CMAKE_INSTALL_PREFIX})
endif ()

#==
# Build target
#==

# Collect a list of header directories
file(GLOB TENSORFLOW_HDRS RELATIVE ${TENSORFLOW_SRC_DIR}/include ${TENSORFLOW_SRC_DIR}/include/*)
foreach (subdir ${TENSORFLOW_HDRS})
    list(APPEND TENSORFLOW_SRC_HEADERS ${TENSORFLOW_SRC_DIR}/include/${subdir})
    list(APPEND TENSORFLOW_HEADERS ${TENSORFLOW_INSTALL_DIR}/include/${subdir})
endforeach ()
list(APPEND TENSORFLOW_SRC_HEADERS ${TENSORFLOW_SRC_DIR}/include/bazel-genfiles)
list(APPEND TENSORFLOW_HEADERS ${TENSORFLOW_INSTALL_DIR}/include/bazel-genfiles)

# Collect a list of library binaries
FILE(GLOB TENSORFLOW_LIBS RELATIVE ${TENSORFLOW_SRC_DIR}/lib ${TENSORFLOW_SRC_DIR}/lib/*)
foreach (lib ${TENSORFLOW_LIBS})
    list(APPEND TENSORFLOW_SRC_LIBRARIES ${TENSORFLOW_SRC_DIR}/lib/${lib})
    list(APPEND TENSORFLOW_LIBRARIES ${TENSORFLOW_INSTALL_DIR}/lib/${lib})
endforeach ()

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
