FROM janchk/tf_base:debian_bullseye_gpu-base

USER root

ENV BUILD_DIRECTORY /tmp
RUN \
	ldconfig && \
	cd $BUILD_DIRECTORY && git clone https://github.com/janchk/tensorflow-cpp/ && cd tensorflow-cpp && git checkout automated_build \
	&& mkdir build && cd build && \
	cmake \
	-DTENSORFLOW_ROOT=/root/.tensorflow/lib \
	-DCMAKE_INSTALL_PREFIX=/usr/local/ \
	-DCMAKE_BUILD_TYPE=Release \
	-DPYTHON_LIB_PATH=/usr/local/lib/python3.8/dist-packages \
	-DTF_NEED_CUDA=ON \
	-DCUDA_COMPUTE_CAPABILITIES=7.5 \
	-DCUDA_TOOLKIT_PATH=/usr/local/cuda \
	-DCUDNN_INSTALL_PATH=/usr/lib/x86_64-linux-gnu \
	-DGCC_HOST_COMPILER_PATH=/usr/bin/gcc-8 \
	-DTF_CUDA_VERSION=10.1 \
	.. \
	&& cd $BUILD_DIRECTORY/tensorflow-cpp/build/tensorflow_src && wget https://raw.githubusercontent.com/clearlinux-pkgs/tensorflow/master/Add-grpc-fix-for-gettid.patch \
	&& patch -p1 <Add-grpc-fix-for-gettid.patch \
	&& cd $BUILD_DIRECTORY/tensorflow-cpp/build/tensorflow_src/third_party && rm Rename-gettid-functions.patch && wget https://nomeroff.net.ua/tf/Rename-gettid-functions.patch


ENV PATH /usr/local/bin:/home/.local/bin/:${PATH}

RUN \
	cd $BUILD_DIRECTORY/tensorflow-cpp/build && make TensorflowLIB && make install \
	&& cmake \
	-DTENSORFLOW_ROOT=/root/.tensorflow/lib \
	-DCMAKE_INSTALL_PREFIX=/usr/local/ \
	-DCMAKE_BUILD_TYPE=Release \
	-DPYTHON_LIB_PATH=/usr/local/lib/python3.8/dist-packages \
	-DTF_NEED_CUDA=ON \
	-DCUDA_COMPUTE_CAPABILITIES=7.5 \
	-DCUDA_TOOLKIT_PATH=/usr/local/cuda \
	-DCUDNN_INSTALL_PATH=/usr/lib/x86_64-linux-gnu \
	-DGCC_HOST_COMPILER_PATH=/usr/bin/gcc-8 \
	-DTF_CUDA_VERSION=10.1 \
	.. \
	cd $BUILD_DIRECTORY/tensorflow-cpp/build && make TensorflowLIB && make install \
	&& cd $BUILD_DIRECTORY/tensorflow-cpp/abseil && ./build.sh \
	&& cd $BUILD_DIRECTORY/tensorflow-cpp/protobuf && ./build.sh \
	&& cp -r $BUILD_DIRECTORY/tensorflow-cpp/tensorflow/examples /home/examples \
	&& mkdir /home/examples/build && cd /home/examples/build && cmake .. && make && ./tf_hello_world \
	&& echo "Cleaning build directory..." && rm -rf /tmp/* && rm -rf /root/.cache/bazel/*
