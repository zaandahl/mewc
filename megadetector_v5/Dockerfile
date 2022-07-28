# set base image (host OS)
FROM zaandahl/mewc_torch:latest

# set the working directory in the container
WORKDIR /code

# clone megadetector repos
RUN git clone --depth 1 -b v5.0 https://github.com/Microsoft/cameratraps
RUN git clone --depth 1 -b v5.0 https://github.com/Microsoft/ai4eutils
RUN git clone --depth 1 https://github.com/ultralytics/yolov5/
#RUN cd /code/yolov5
#RUN git checkout c23a441c9df7ca9b1f275e8c8719c949269160d1
ENV PYTHONPATH "${PYTHONPATH}:/code/cameratraps:/code/ai4eutils:/code/yolov5"

# download the megadetector model
RUN wget -O /code/md_v5a.0.0.pt https://github.com/microsoft/CameraTraps/releases/download/v5.0/md_v5a.0.0.pt
RUN wget -O /code/md_v5b.0.0.pt https://github.com/microsoft/CameraTraps/releases/download/v5.0/md_v5b.0.0.pt

# copy the content of the local src directory to the working directory
COPY src/ .

# run megadetector wrapper script
CMD [ "python", "./megadetector.py" ]