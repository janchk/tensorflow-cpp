#!/bin/bash

# Set default versions
BZL_VERSION="0.25.0"
TF_VARIANT="gpu"

# Set the default version and variant
if [ -z "${TF_VERSION}" ];
then TF_VERSION="1.15";
fi
if [ -z ${TF_VARIANT} ];
then TF_VARIANT="gpu";
fi

# TODO: check version of TF to determine version of Bazel to install
echo "TensorFlow: Building ${TF_VERSION}-${TF_VARIANT} using Bazel ${BZL_VERSION}";

# Set the default source directory
if [ -z "${TF_SRC}" ];
then
  TF_SRC="${HOME}/.tensorflow/src";
  echo "TensorFlow: Build: Using default source path: ${TF_SRC}";
else
  echo "TensorFlow: Build: Using source path: ${TF_SRC}";
fi

 Download and install Bazel
if ! [ -x "$(command -v bazel)" ];
then
  echo "TensorFlow: Build: Installing Bazel ${BZL_VERSION}";
  wget https://github.com/bazelbuild/bazel/releases/download/${BZL_VERSION}/bazel-${BZL_VERSION}-installer-linux-x86_64.sh -P /tmp/bazel/
  chmod +x /tmp/bazel/bazel-${BZL_VERSION}-installer-linux-x86_64.sh
  /tmp/bazel/bazel-${BZL_VERSION}-installer-linux-x86_64.sh --prefix=/home/$USER/.local
fi

# Clone TensorFlow source
if ! [ -d "${TF_SRC}" ];
then
  echo "TensorFlow: Build: Cloning TensorFlow";
  git clone https://github.com/tensorflow/tensorflow.git "${TF_SRC}";
  git checkout v1.15.3;
fi

