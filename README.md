# TensorFlow CMake

This repository represents a fork of [this](https://github.com/leggedrobotics/tensorflow-cpp) repository. With some changes 

* Upgraded Tensorflow version
* Removed binaries
* Changed parameters for bazel build

This repository provides scripts for compiling and installing TensorFlow for C/C++ (headers + libraries) and CMake.

**Maintainer:** Jan Akhremchik  

## Overview

This repository provides TensorFlow libraries with the following specifications:  

  - Provided versions: `1.14` (Default)
  - Supports Ubuntu 18.04 LTS (GCC >=7.4).  
  - Provides variants Nvidia GPU.  
  - GPU variants are built to support compute capabilities:  `6.1`, `7.0`, `7.2`, `7.5`  

**NOTE:** This repository does not include or bundle the source TensorFlow [repository](https://github.com/tensorflow/tensorflow).

## Install

First clone this repository:
```bash
git clone https://github.com/janchk/tensorflow-cpp.git
```

### Eigen

To install the special version of Eigen requried by TensorFlow that we also bundle in this repository:
```bash
cd tensorflow/eigen
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=~/.local -DCMAKE_BUILD_TYPE=Release ..
make install -j{your core count}
```
**NOTE:** We recommend installing to `~/.local` in order to prevent conflicts with other version of Eigen which may be installed via `apt`. Eigen exports its package during the build step, so CMake will default to finding the one we just installed unless a `HINT` is used or `CMAKE_PREFIX_PATH` is set to another location.  

### Protobuf

You could install protobuf by yourself following this [instruction](https://github.com/protocolbuffers/protobuf/blob/master/src/README.md).

**NOTE:** You need to use version 3.7.1

As alternative you could use script `build.sh` in `tensorflow-cpp/protobuf` which installing protobuf **system-wide**

### Abseil 

Use [this](https://github.com/abseil/abseil-cpp) repository for installation.

**NOTE:** Install abseil AFTER tensorflow

### TensorFlow

These are the options for using the TensorFlow CMake package:

**Option 1 (Recommended):** Installing into the (local) file system
```bash
cd tensorflow/tensorflow
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=~/.local -DCMAKE_BUILD_TYPE=Release ..
make install -j{your core count}
```
**NOTE:** The CMake will download all required sources for `tensorflow` and then build them.

**Option 2 (Advanced):** Create symbolic link to your target workspace directory:
```bash
ln -s /<SOURCE-PATH>/tensorflow/tensorflow <TARGET-PATH>/
```

## Use

TensorFlow CMake can be included in other projects either using the `find_package` command:
```CMake
...
find_package(TensorFlow CONFIG REQUIRED)
...
```

or alternatively included directly into other projects using the `add_subdirectory` command
```CMake
...
add_subdirectory(/<SOURCE-PATH>/tensorflow/tensorflow)
...
```
**NOTE:** By default the CMake package will select the CPU-only variant of a given library version and defining/setting the `TF_USE_GPU` option variable reverts to the GPU-enabled variant.

User targets such as executables and libraries can now include the `TensorFlow::TensorFlow` CMake target using the `target_link_libraries` command.
```CMake
add_executable(tf_hello src/main.cpp)
target_link_libraries(tf_hello PUBLIC TensorFlow::TensorFlow)
target_compile_features(tf_hello PRIVATE cxx_std_14)
```
**NOTE:** For more information on using CMake targets please refer to this excellent [article](https://pabloariasal.github.io/2018/02/19/its-time-to-do-cmake-right/).


## Customize

If a specialized build of TensorFlow (e.g. different verion of CUDA, NVIDIA Compute Capability, AVX etc) is required, then the following steps can be taken:  
1. Follow the standard [instructions](https://www.tensorflow.org/install/source) for installing system dependencies.  
**NOTE:** For GPU-enabled systems, additional [steps](https://www.tensorflow.org/install/gpu) need to be taken.  
2. View and/or modify our utility [script](https://github.com/leggedrobotics/tensorflow-cpp/blob/master/tensorflow/bin/build.sh) for step-by-step instructions for building, extracting and packaging all headers and libraries generated by Bazel from building TensorFlow.  
3. Set the `TENSORFLOW_ROOT` variable with the name of the resulting directory:
```bash
cmake -DTENSORFLOW_ROOT=~/.tensorflow/lib -DCMAKE_INSTALL_PREFIX=~/.local -DCMAKE_BUILD_TYPE=Release ..
```

## Common problems
* `error: 'int128' does not name a type; did you mean 'uint128'?` - Try to reinstall abseil
* `libtensorflow_cc.so.1: cannot open shared object file: No such file or directory` - Try `sudo ldconfig`

## License

[Apache License 2.0](LICENSE)
