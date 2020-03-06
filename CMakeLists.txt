cmake_minimum_required(VERSION 3.10)
project(TensorflowLIB)
include(ExternalProject)

set(TF_SCRPT ${PROJECT_SOURCE_DIR}/tensorflow/bin)

set(TF_PREPARE_SCRIPT "${TF_SCRPT}/prepare.sh")
set(TF_BUILD_SCRIPT "${TF_SCRPT}/build.sh")

set(TF_SRC "${PROJECT_BINARY_DIR}/tensorflow_src")
set(TF_LIB "${PROJECT_BINARY_DIR}/tensorflow_lib")

set(ENV{TF_SRC} "${TF_SRC}")
set(ENV{TF_LIB} "${TF_LIB}")


execute_process(COMMAND ${TF_PREPARE_SCRIPT})

#configure_file(${CMAKE_CURRENT_SOURCE_DIR}/tensorflow/bin/tf_configure.bazelrc.gpu ${TF_SRC}/tf_configure.bazelrc.gpu COPYONLY)

add_custom_target(TensorflowLIB ALL
#        COMMAND /bin/sh ${TF_SRC}/configure
        COMMAND echo "Start building TENSORFLOW"
        COMMAND ${CMAKE_COMMAND} -E env " TF_LIB=${TF_LIB}" "TF_SRC=${TF_SRC}" "TF_SCRPT=${TF_SCRPT}" /bin/sh ${TF_BUILD_SCRIPT}
#        USES_TERMINAL
        )

#add_custom_command(TARGET TensorflowLIB
#        PRE_BUILD
#        COMMAND echo "PREBUILD!!")
#execute_process(COMMAND ${TF_BUILD_SCRIPT} -E echo "Building Tensorflow ")


#ExternalProject_Add_StepTargets(TensorflowLIB configure build install)

#add_dependencies(TensorflowLIB-configure TensorflowLIB-build TensorflowLIB-install)

#set
#execute_process(COMMAND)
#add_subdirectory(tensorflow)
