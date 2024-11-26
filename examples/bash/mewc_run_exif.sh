#!/bin/bash

# Default values for input and parameter directories
SERVICE_DIR="${1:-.}"
PARAM_ENV="${2:-.}"

# Resolve absolute paths
SERVICE_DIR=$(realpath "$SERVICE_DIR")
PARAM_ENV=$(realpath "$PARAM_ENV")

# Function to run MEWC exif script
mewc_script() {
  local in_dir=$1
  local params=$2
  echo "Starting EXIF processing for folder: $in_dir with params: $params"
  docker run --env CUDA_VISIBLE_DEVICES="0" --env-file "${params}" --gpus all --interactive --rm --volume "${in_dir}:/images" zaandahl/mewc-exif
  echo "Finished EXIF processing for folder: $in_dir"
}

# Pull the Docker image
docker pull zaandahl/mewc-exif

# Collect directories into an array
folders=($(find "$SERVICE_DIR" -type d -not -path "*/animal/*" -not -path "*/blank/*" -not -path "*/human/*" -not -path "*/snips/*"))

# Iterate over the collected directories
for folder in "${folders[@]}"; do
    if [ -d "$folder/snips" ] && (ls "$folder"/*.csv 1> /dev/null 2>&1 || ls "$folder"/*.pkl 1> /dev/null 2>&1); then
        mewc_script "$folder" "$PARAM_ENV"
    else
        echo "Skipping $folder (missing 'snips' subfolder or no .csv/.pkl file found)"
    fi
done
