# TensorFlow CMake

This repository is a modified version of [that](https://github.com/janchk/tensorflow-cpp) repo with accent on automated building.

**Maintainer:** Jan Akhremchik  

## Overview

This repository provides TensorFlow libraries with the following specifications:  

  - Provided versions: `1.15` (Default)
  - Supports Ubuntu 18.04 LTS (GCC >=7.4).  
  - Provides variants Nvidia GPU.  

## Install

First clone this repository and checkout to automated branch:
```bash
git clone https://github.com/janchk/tensorflow-cpp.git
git checkout automated_build
```

### Eigen

To install the special version of Eigen requried by TensorFlow that we also bundle in this repository:
```bash
cd tensorflow/eigen
mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=~/.local -DCMAKE_BUILD_TYPE=Release ..
make install -j{your core count}
```


### Cmake arguments

You can pass this arguments directly or use `cmake-gui` to handle them in easy way

`WITH_ABSEIL`\
`WITH_EIGEN`\
`WITH_PROTOBUF`\
`CMAKE_INSTALL_PREFIX`\
`CUDA_COMPUTE_CAPABILITIES`\
`CUDA_TOOLKIT_PATH`\
`CUDNN_INSTALL_PATH`\
`PYTHON_BIN_PATH`\
`PYTHON_LIB_PATH`\
`TF_CUDA_CLANG`\
`TF_CUDA_VERSION`\
`TF_NEED_CUDA`\
`TF_NEED_TENSORRT`


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
* `fatbinary external/nccl_archive/device_dlink_hdrs.fatbin failed (Exit 1)` - 
This problem may appear in case you using cuda  v 10.2. Workaround is to remove the line 
`"--bin2c-path=%s" % bin2c.dirname`, from the file `third_party/nccl/build_defs.bzl.tpl`

## License

[Apache License 2.0](LICENSE)
