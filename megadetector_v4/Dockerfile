# set base image (host OS)
FROM zaandahl/mewc_flow:latest

# set the working directory in the container
WORKDIR /code

# clone megadetector repos
RUN git clone --depth 1 https://github.com/Microsoft/cameratraps
RUN git clone --depth 1 https://github.com/Microsoft/ai4eutils
ENV PYTHONPATH "${PYTHONPATH}:/code/cameratraps:/code/ai4eutils"

# download the megadetector model
RUN wget -O /code/md_v4.1.0.pb https://lilablobssc.blob.core.windows.net/models/camera_traps/megadetector/md_v4.1.0/md_v4.1.0.pb

# copy the content of the local src directory to the working directory
COPY src/ .

# run megadetector wrapper script
CMD [ "python", "./megadetector.py" ]