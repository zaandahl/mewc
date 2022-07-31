# set base image (host OS)
FROM pytorch/pytorch:1.12.0-cuda11.3-cudnn8-runtime
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg \
    libsm6 \
    libxext6 \
    git \
    wget \
    && rm -rf /var/lib/apt/lists/*

# set the working directory in the container
WORKDIR /code

# copy the dependencies file to the working directory
COPY requirements_torch.txt .

# install dependencies
RUN pip install -r requirements_torchß.txt
