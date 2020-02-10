#!/bin/bash
# Install specific version of Protobuf (3.7.1) - tf 1.14
# Install specific version of Protobuf (3.8.0) - tf 1.15

echo "TensorFlow: Build: Cloning Protobuf";
git clone https://github.com/protocolbuffers/protobuf.git ${TF_SRC};
cd protobuf
git submodule update --init --recursive
git checkout v3.7.1
./autogen.sh
./configure

echo "TensorFlow: Build: Building Protobuf";
make -j8
make check -j8

echo "TensorFlow: Build: Installing Protobuf system-wide";
make install
sudo ldconfig


