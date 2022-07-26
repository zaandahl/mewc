# set base image (host OS)
FROM pytorch/pytorch:latest
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
