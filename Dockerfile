# Use NVIDIA CUDA 12.4.1 cuDNN Developer as the base image
FROM nvidia/cuda:12.4.1-cudnn-devel-ubuntu22.04
# FROM nvidia/cuda:12.8.0-cudnn-devel-ubuntu24.04

# Set a non-interactive environment to prevent issues during installations
ENV DEBIAN_FRONTEND=noninteractive

ARG USERNAME=myuser
ARG USER_UID=1000
ARG USER_GID=1000

# Update and install necessary dependencies
RUN apt update && apt install -y \
    bash \
    build-essential \
    cmake \
    cmake-curses-gui \
    curl \
    git \
    gpg-agent \
    htop \
    mesa-utils \
    ncdu \
    sudo \
    tmux \
    tree \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install OpenCV dependencies
RUN apt-get update && apt-get install -y \
    libcanberra-gtk-module \
    libeigen3-dev \
    libgflags-dev \
    # libgstreamer-plugins-bad1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    # libgstreamer-plugins-good1.0-dev \
    libgstreamer1.0-dev \
    libgtk2.0-dev \
    libgtkglext1 \
    libgtkglext1-dev \
    libjpeg-dev \
    # libtbb-dev \
    libtiff-dev \
    # libvtk9-dev \
    libwebp-dev \
    python3-dev \
    python3-numpy \
    # qtbase5-dev \
    && rm -rf /var/lib/apt/lists/*

# libvtk9-dev depends on libtbb-dev 
# this causes a conflict with the Intel MKL installation.

# Install ceres dependencies
# RUN apt-get update && apt-get install -y \
#     libgoogle-glog-dev \
#     libmetis-dev \
#     libsuitesparse-dev \
#     && rm -rf /var/lib/apt/lists/*

# Install Intel MKL
RUN wget -qO- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
    | gpg --dearmor -o /usr/share/keyrings/oneapi-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
    > /etc/apt/sources.list.d/oneAPI.list \
    && apt-get update && apt-get install -y \
    intel-oneapi-mkl \
    intel-oneapi-mkl-devel

# Build and install Ceres Solver
# RUN mkdir -p /var/dependencies \
#     && cd /var/dependencies \
#     && git clone --depth 1 --branch 2.2.0 https://github.com/ceres-solver/ceres-solver.git ceres-solver \
#     && cd ceres-solver \
#     && . /opt/intel/oneapi/setvars.sh \
#     && cmake -B builddir \
#     && cmake --build builddir -- -j$(nproc) \
#     && cmake --install builddir --prefix /usr/local

# Build and install OpenCV
RUN mkdir -p /var/dependencies \
    && cd /var/dependencies \
    && git clone --depth 1 --branch 4.11.0 https://github.com/opencv/opencv.git opencv \
    && git clone --depth 1 --branch 4.11.0 https://github.com/opencv/opencv_extra.git \
    && git clone --depth 1 --branch 4.11.0 https://github.com/opencv/opencv_contrib.git \
    && cd opencv \
    && cmake \
        -D CMAKE_BUILD_TYPE=Release \
        -D ENABLE_FAST_MATH=ON \
        -D CUDA_FAST_MATH=ON \
        -D WITH_CUBLAS=ON \
        -D WITH_CUDA=ON \
        -D OPENCV_DNN_CUDA=ON \
        -D WITH_OPENGL=ON \
        -D WITH_TBB=ON \
        -D WITH_GSTREAMER=ON \
        -D WITH_GTK=ON \
        -D WITH_GTK_2_X=ON \
        -D WITH_QT=OFF \
        -D WITH_VTK=OFF \
        -D BUILD_opencv_cudacodec=ON \
        -D WITH_NVCUVID=OFF \
        -D WITH_NVCUVENC=OFF \
        -D BUILD_EXAMPLES=ON \
        -D BUILD_TESTS=ON \
        -D MKL_ROOT_DIR=/opt/intel/oneapi/mkl/latest \
        -D MKL_WITH_TBB=ON \
        -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib/modules \
        -B builddir \
    && cmake --build builddir -- -j$(nproc) \
    && cmake --install builddir --prefix /usr/local

# Create a non-root user with sudo privileges
# Remove conflicting user/group
RUN if getent passwd ${USER_UID}; then \
      userdel -f $(getent passwd ${USER_UID} | cut -d: -f1); \
    fi \
    && if getent group ${USER_GID}; then \
      groupdel $(getent group ${USER_GID} | cut -d: -f1); \
    fi

# Create user and give sudo
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} --shell /bin/bash --create-home ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers    

CMD ["sleep", "infinity"]
