# Use an official Python runtime as a parent image
FROM nvidia/cuda:12.1-cudnn8-runtime-ubuntu20.04

# Set the working directory in the container
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    ffmpeg \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install conda
RUN apt-get update && apt-get install -y wget bzip2 && \
    wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

# Add conda to PATH
ENV PATH /opt/conda/bin:$PATH

# Copy the current directory contents into the container at /app
COPY . /app

# Create the conda environment
RUN conda create -n hallo python=3.10 && \
    echo "conda activate hallo" >> ~/.bashrc

# Activate the conda environment and install dependencies
RUN /bin/bash -c "source ~/.bashrc && conda activate hallo && pip install -r requirements.txt && pip install ."

# Download pretrained models
RUN /bin/bash -c "source ~/.bashrc && conda activate hallo && git lfs install && git clone https://huggingface.co/fudan-generative-ai/hallo pretrained_models"

# Install Flask
RUN /bin/bash -c "source ~/.bashrc && conda activate hallo && pip install flask"

# Copy the Flask app into the container
COPY app.py /app/app.py

# Expose port 5000 for the API
EXPOSE 5000

# Update the CMD to run the Flask app
CMD ["/bin/bash", "-c", "source ~/.bashrc && conda activate hallo && python app.py"]
