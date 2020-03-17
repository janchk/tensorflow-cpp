#!/bin/bash

# Set default versions
BZL_VERSION="0.25.0"
TF_VARIANT="gpu"

# Set the default version and variant
if [ -z ${TF_VERSION} ]; then
  TF_VERSION="1.15"
fi
if [ -z ${TF_VARIANT} ]; then
  TF_VARIANT="gpu"
fi

# Set the default output directory
if [ -z "${TF_LIB}" ]; then
  TF_LIB="${HOME}/.tensorflow/lib/${TF_VERSION}-${TF_VARIANT}"
  echo "TensorFlow: Build: Using default output path: ${TF_LIB}"
else
  echo "TensorFlow: Build: Using output path: ${TF_LIB}"
fi

# Clear any existing directories
if [ -d "${TF_LIB}" ]; then
  rm -rf "${TF_LIB}"
  echo "TensorFlow: Build: Removing existing directory: ${TF_LIB}"
fi

# Configure and build TensorFlow
if [ -d "${TF_SRC}/bazel-bin" ]; then
  echo "TensorFlow: Build: Removing symlinks to previous build"
  rm -r "${TF_SRC}"/bazel-*
fi

#if [ -z "${TF_SCRPT}" ]; then
#  cp tf_configure.bazelrc.${TF_VARIANT} "${TF_SRC}"/.tf_configure.bazelrc
#else
#  cp "${TF_SCRPT}"/tf_configure.bazelrc.${TF_VARIANT} "${TF_SRC}"/.tf_configure.bazelrc
#fi

#if [ "${TF_VARIANT}" == "gpu" ]; then
#  echo "build --action_env LD_LIBRARY_PATH=\":${HOME}/.local/lib\"" >>"${TF_SRC}"/.tf_configure.bazelrc
#fi

cd ${TF_SRC}
git checkout r${TF_VERSION}
echo "TensorFlow: Build: Building 'libtensorflow_cc'"
echo  " TensorFlow_lib ${TF_LIB}"
bazel build //tensorflow:libtensorflow_cc.so

# Create the output directories
mkdir -p ${TF_LIB}/include/third_party
mkdir -p ${TF_LIB}/include/tensorflow
mkdir -p ${TF_LIB}/include/nsync
mkdir -p ${TF_LIB}/include/gemmlowp
mkdir -p ${TF_LIB}/include/bazel-genfiles
mkdir -p ${TF_LIB}/lib

# Copy all source contents
echo "TensorFlow: Build: Copying headers"
cp -r -L ${TF_SRC}/bazel-genfiles/* ${TF_LIB}/include/bazel-genfiles

#cp -r -L ${TF_SRC}/bazel-src/tensorflow/* ${TF_LIB}/include/tensorflow
#cp -r -L ${TF_SRC}/bazel-src/external/nsync/public ${TF_LIB}/include/nsync/
#cp -r -L ${TF_SRC}/bazel-src/external/gemmlowp/public ${TF_LIB}/include/gemmlowp/

cp -r -L ${TF_SRC}/bazel-tensorflow_src/tensorflow/* ${TF_LIB}/include/tensorflow
cp -r -L ${TF_SRC}/bazel-tensorflow_src/external/nsync/public ${TF_LIB}/include/nsync/
cp -r -L ${TF_SRC}/bazel-tensorflow_src/external/gemmlowp/public ${TF_LIB}/include/gemmlowp/

# cp -r -L ${TF_SRC}/bazel-src/external/protobuf_archive/src/* ${TF_LIB}/include/

#cp -r -L ${TF_SRC}/bazel-src/external/com_google_absl/absl ${TF_LIB}/include/
#cp -r -L ${TF_SRC}/bazel-src/third_party/* ${TF_LIB}/include/third_party/

cp -r -L ${TF_SRC}/bazel-tensorflow_src/external/com_google_absl/absl ${TF_LIB}/include/
cp -r -L ${TF_SRC}/bazel-tensorflow_src/third_party/* ${TF_LIB}/include/third_party/

# Remove all files which are not header files, and remove all residual empty directories
find ${TF_LIB}/include -type f -not -name '*.h' -not -name "*.cuh" -not -name "*.hpp" -delete
find ${TF_LIB}/include -empty -type d -delete

# Copy TensorFlow-specific Eigen3 headers
mkdir -p ${TF_LIB}/include/third_party/eigen3
cp -r -L ${TF_SRC}/third_party/eigen3 ${TF_LIB}/include/third_party/

# Copy binary contents
echo "TensorFlow: Build: Copying libraries"
cp ${TF_SRC}/bazel-bin/tensorflow/libtensorflow_cc.so ${TF_LIB}/lib/
cp ${TF_SRC}/bazel-bin/tensorflow/libtensorflow_framework.so.1 ${TF_LIB}/lib/libtensorflow_framework.so

# cp ${TF_SRC}/bazel-src/bazel-out/host/bin/external/protobuf_archive/libprotobuf.so ${TF_LIB}/lib;

# Completion
echo "TensorFlow: Build: Done!"

#
