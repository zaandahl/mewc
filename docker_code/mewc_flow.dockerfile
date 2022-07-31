# set base image (host OS)
FROM tensorflow/tensorflow:2.9.1-gpu
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
COPY requirements_flow.txt .

# install dependencies
RUN pip install -r requirements_flow.txt
