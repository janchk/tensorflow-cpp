#!/bin/bash
# Install spec ific version of Protobuf (3.8.0)

echo "TensorFlow: Build: Cloning Protobuf";
git clone https://github.com/protocolbuffers/protobuf.git ${TF_SRC};
cd protobuf
git submodule update --init --recursive
git checkout 3.8.x
./autogen.sh
./configure

echo "TensorFlow: Build: Building Protobuf";
make -j8
make check -j8

echo "TensorFlow: Build: Installing Protobuf system-wide";
make install
sudo ldconfig


