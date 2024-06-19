# Use an official Python runtime as a parent image
FROM nvidia/cuda:12.1.0-cudnn8-runtime-ubuntu20.04

# Set the working directory in the container
WORKDIR /app

ENV DEBIAN_FRONTEND="noninteractive"
ENV TZ="Etc/UTC" 

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    bzip2 \
    ffmpeg \
    git \
    build-essential \
    cmake \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    /opt/conda/bin/conda clean --all --yes && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> /etc/profile && \
    echo "conda activate base" >> /etc/profile

# Add conda to PATH
ENV PATH /opt/conda/bin:$PATH

# Copy the current directory contents into the container at /app
COPY . /app

# Create the conda environment
RUN /opt/conda/bin/conda create -n hallo python=3.10 && \
    echo "conda activate hallo" >> /etc/profile

# Activate the conda environment and install dependencies
RUN /bin/bash -c "source /etc/profile && conda activate hallo && pip install --upgrade pip setuptools wheel && pip install -r requirements.txt && pip install ."

ENV GIT_TRACE=1
ENV GIT_TRANSFER_TRACE=1
ENV GIT_CURL_VERBOSE=1

# Install Git LFS
RUN apt-get update && apt-get install -y git-lfs && git lfs install

# Download pretrained models
RUN /bin/bash -c "source /etc/profile && conda activate hallo && git lfs install && git clone https://huggingface.co/fudan-generative-ai/hallo pretrained_models && cd pretrained_models && git lfs pull"

# Install Flask
RUN /bin/bash -c "source ~/.bashrc && conda activate hallo && pip install flask"

# Copy the Flask app into the container
COPY app.py /app/app.py

# Expose port 5000 for the API
EXPOSE 5000

# Update the CMD to run the Flask app
CMD ["/bin/bash", "-c", "source ~/.bashrc && conda activate hallo && python app.py"]
