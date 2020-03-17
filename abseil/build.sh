#!/bin/bash

echo "Initing abseil repo!"
git submodule update --init --recursive
cd abseil-cpp
mkdir build && cd build
cmake ..
make -j
make install


