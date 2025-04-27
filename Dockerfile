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
    libtbb-dev \
    libtiff-dev \
    libvtk9-dev \
    libwebp-dev \
    python3-dev \
    python3-numpy \
    # qtbase5-dev \
    && rm -rf /var/lib/apt/lists/*

# Install ceres dependencies
RUN apt-get update && apt-get install -y \
    libgoogle-glog-dev \
    libmetis-dev \
    libsuitesparse-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Intel MKL
RUN wget -qO- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
    | gpg --dearmor -o /usr/share/keyrings/oneapi-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
    > /etc/apt/sources.list.d/oneAPI.list \
    && apt-get update && apt-get install -y \
    intel-oneapi-mkl \
    intel-oneapi-mkl-devel

# Build and install Ceres Solver
RUN mkdir -p /var/dependencies \
    && cd /var/dependencies \
    && git clone --depth 1 --branch 2.2.0 https://github.com/ceres-solver/ceres-solver.git ceres-solver \
    && cd ceres-solver \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make -j$(nproc) \
    # && make test -j$(nproc) \
    && make install


# Install Kokkos
# RUN mkdir -p /var/dependencies \
#     && cd /var/dependencies \
#     && git clone --depth 1 --branch 4.5.01 https://github.com/kokkos/kokkos.git kokkos \
#     && cd kokkos \
#     && cmake -B builddir \
#         -DCMAKE_CXX_STANDARD=17 \
#         -DKokkos_ENABLE_OPENMP=ON \
#         -DKokkos_ARCH_ADA89=ON \
#         -DKokkos_ENABLE_CUDA=ON \
#         -DKokkos_ENABLE_IMPL_CUDA_MALLOC_ASYNC=ON \
#         -DKokkos_ARCH_NATIVE=ON \
#         -DKokkos_ENABLE_DEPRECATED_CODE_4=OFF \
#         -DKokkos_ENABLE_EXAMPLES=ON \
#     && cmake --build builddir -- -j$(nproc) \
#     && cmake --install builddir --prefix /usr/local

# Create a non-root user with sudo privileges
RUN groupadd --gid ${USER_GID} ${USERNAME} \
    && useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

CMD ["sleep", "infinity"]
