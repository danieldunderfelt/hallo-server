# Use an official CUDA and Ubuntu base image
FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu20.04

# Set the working directory in the container
WORKDIR /app

# Set noninteractive to prevent prompts during package installation
ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ="Etc/UTC"

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    bzip2 \
    ffmpeg \
    git \
    git-lfs \
    build-essential \
    cmake \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda and clean up in a single layer
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    /opt/conda/bin/conda clean --all --yes

# Add Conda to PATH
ENV PATH /opt/conda/bin:$PATH

# Create the conda environment
RUN conda create -n hallo python=3.10 -y && \
    conda init bash

# Activate conda environment by setting the PATH
ENV PATH /opt/conda/envs/hallo/bin:$PATH

# Copy the current directory contents into the container at /app
COPY . /app

# Install Python packages in the created conda environment
RUN pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt && \
    pip install .

# Copy the Flask app into the container
COPY app.py /app/app.py

# Expose port 5000 for the API
EXPOSE 5000

# Set the command to run the Flask app
CMD ["python", "app.py"]
