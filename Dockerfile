#original from original git repo
FROM python:3.8.16-bullseye

# only to try to get ROCm to work and ROCm just refused to work on container
# FROM python:3.8.18-bookworm 

# ROCm stuff that just doesn't work
# Windows/Linux HOST (not the container necessarily) Machine must have the kernal drivers
# For Windows: https://www.amd.com/en/developer/resources/rocm-hub/hip-sdk.html (https://rocm.docs.amd.com/en/latest/deploy/windows/quick_start.html)
# For Linux:  apt install amdgpu-dkms (https://rocm.docs.amd.com/en/latest/deploy/linux/quick_start.html)
# For Linux: apt install rocm-hip-libraries

# Thought this would work for ROCm
# Docker hub: https://hub.docker.com/r/rocm/pytorch/tags?page=1&name=1.12
# FROM rocm/pytorch:rocm5.6_ubuntu20.04_py3.8_pytorch_1.12.1
ARG DEBIAN_FRONTEND=noninteractive

# RUN /opt/rocm/bin/rocminfo
# RUN /opt/rocm/opencl/bin/clinfo

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common \
    wget \
    git \
    build-essential \
    libgl1 \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libjpeg-dev \
    libpng-dev \
    unzip \
    ffmpeg

# Tried to get ROCm to work
# RUN apt install rock-dkms -y

# Set the working directory
WORKDIR /app

# Clone Risharde's forked version of SadTalker repository
RUN git clone https://github.com/risharde/SadTalker.git

# Change the working directory to SadTalker
WORKDIR /app/SadTalker

# Checkout the docker AMD GPU branch
RUN git fetch
RUN git checkout docker_amd

# Install PyTorch with CUDA 11.3 support (NVIDIA)
RUN pip install torch==1.12.1+cu113 torchvision==0.13.1+cu113 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu113

# TRY DIRECTML approach
RUN pip install pytorch-directml


# RUN apt install rocm-dev

# TRY pyTorch with AMD SUPPORT (ROCm): Latest version at the time
# Latest versions: https://pytorch.org/get-started/locally/
# RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/rocm5.4.2

# TRY pyTorch with AMD SUPPORT (ROCm): Previous versions at the time
# Previous versions: https://pytorch.org/get-started/previous-versions/
# RUN pip install torch==1.13.1+rocm5.2 torchvision==0.14.1+rocm5.2 torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/rocm5.2
# RUN pip install torch==1.13.0+rocm5.2 torchvision==0.14.0+rocm5.2 torchaudio==0.13.0 --extra-index-url https://download.pytorch.org/whl/rocm5.2
# RUN pip install torch==1.12.1+rocm5.1.1 torchvision==0.13.1+rocm5.1.1 torchaudio==0.12.1 --extra-index-url  https://download.pytorch.org/whl/rocm5.1.1
# RUN pip install torchaudio==0.12.1

# RUN pip install torch-directml
# Think about DIRECTML to SUPPORT AMD - THIS MIGHT ONLY BE WINDOWS SPECIFIC - DEFERRED
# https://github.com/microsoft/DirectML/tree/master/PyTorch

# Install dlib
RUN pip install dlib-bin

# Install GFPGAN
RUN pip install git+https://github.com/TencentARC/GFPGAN

# Install dependencies from requirements.txt
RUN pip install -r requirements.txt

# Download models using the provided script
RUN chmod +x scripts/download_models.sh && scripts/download_models.sh

# ROCm which didn't work
# RUN export HSA_OVERRIDE_GFX_VERSION=10.3.0

ENTRYPOINT ["python3", "inference.py"]