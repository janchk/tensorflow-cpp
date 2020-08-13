FROM debian:testing

USER root
# BEGIN DEFAULT SECTION
RUN \
	echo 'APT::Default-Release "testing";' > /etc/apt/apt.conf.d/80repository \
	    && 	echo "deb     http://deb.debian.org/debian/              testing          main non-free contrib" >  /etc/apt/sources.list \
	    && 	echo "deb     http://deb.debian.org/debian/              testing-updates  main non-free contrib" >> /etc/apt/sources.list \
	    && 	echo "deb     http://deb.debian.org/debian/              unstable         main non-free contrib" >> /etc/apt/sources.list \
	    && 	echo "deb     http://deb.debian.org/debian/              experimental     main non-free contrib" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y wget pkg-config zip g++-8 gcc-8 zlib1g-dev unzip python python3 autoconf libtool curl automake make cmake git libeigen3-dev sudo \
	&& apt-get install -y python3-pip && pip3 install future
# END DEFAULT SECTION

# CUDA section
# base
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 curl ca-certificates && \
    curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub | apt-key add - && \
    echo "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/cuda.list && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list && \
    apt-get purge --autoremove -y curl \
    && rm -rf /var/lib/apt/lists/*

ENV CUDA_VERSION 10.1.243
ENV CUDA_PKG_VERSION 10-1=$CUDA_VERSION-1
# For libraries in the cuda-compat-* package: https://docs.nvidia.com/cuda/eula/index.html#attachment-a
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-cudart-$CUDA_PKG_VERSION \
cuda-compat-10-1 && \
ln -s cuda-10.1 /usr/local/cuda && \
    rm -rf /var/lib/apt/lists/*
# Required for nvidia-docker v1
RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64

ENV NCCL_VERSION 2.4.8
RUN apt-get update && apt-get install -y --no-install-recommends \
    cuda-libraries-$CUDA_PKG_VERSION \
cuda-nvtx-$CUDA_PKG_VERSION \
libcublas10=10.2.1.243-1 \
libnccl2=$NCCL_VERSION-1+cuda10.1 && \
    apt-mark hold libnccl2 && \
    rm -rf /var/lib/apt/lists/*

# CUDA section 
# runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-nvml-dev-$CUDA_PKG_VERSION \
        cuda-command-line-tools-$CUDA_PKG_VERSION \
cuda-libraries-dev-$CUDA_PKG_VERSION \
        cuda-minimal-build-$CUDA_PKG_VERSION \
        libnccl-dev=$NCCL_VERSION-1+cuda10.1 \
libcublas-dev=10.2.1.243-1 

ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs

# CUDA section
# devel
RUN apt-get update && apt-get install -y --no-install-recommends \
        cuda-nvml-dev-$CUDA_PKG_VERSION \
        cuda-command-line-tools-$CUDA_PKG_VERSION \
cuda-libraries-dev-$CUDA_PKG_VERSION \
        cuda-minimal-build-$CUDA_PKG_VERSION \
        libnccl-dev=$NCCL_VERSION-1+cuda10.1 \
libcublas-dev=10.2.1.243-1 

ENV LIBRARY_PATH /usr/local/cuda/lib64/stubs

# CUDA section
# cudnn
ENV CUDNN_VERSION 7.6.5.32

RUN apt-get update && apt-get install -y --no-install-recommends \
    libcudnn7=$CUDNN_VERSION-1+cuda10.1 \
libcudnn7-dev=$CUDNN_VERSION-1+cuda10.1 \
&& \
    apt-mark hold libcudnn7 && \
    rm -rf /var/lib/apt/lists/*
