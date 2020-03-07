cmake_minimum_required(VERSION 3.10)
project(TensorflowLIB)
include(ExternalProject)

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

    set(CUDA_VER "10.2" CACHE STRING "Set Cuda version for GPU build")
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
        COMMAND ${CMAKE_COMMAND} -E env " TF_LIB=${TF_LIB}" "TF_SRC=${TF_SRC}" "TF_SCRPT=${TF_SCRPT}" /bin/sh ${TF_BUILD_SCRIPT}
        )
