#!/bin/bash

echo "Initing abseil repo!"
git submodule update --init --recursive
cd abseil-cpp || pwd
mkdir build && cd build
cmake ..
make -j
sudo make install


