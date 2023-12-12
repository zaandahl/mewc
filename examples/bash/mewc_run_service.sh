#!/bin/bash

# Default values for input, parameter, class list, model, and GPU directories
SERVICE_DIR="${1:-.}"
PARAM_ENV="${2:-.}"
CLASS="${3:-.}"
MODEL="${4:-.}"
GPU="${5:-0}"

# Resolve absolute paths
SERVICE_DIR=$(realpath "$SERVICE_DIR")
PARAM_ENV=$(realpath "$PARAM_ENV")
CLASS=$(realpath "$CLASS")
MODEL=$(realpath "$MODEL")

# Function to run the full MEWC sequence
mewc_script() {
  local in_dir=$1
  local params=$2
  local cl=$3
  local model=$4

  # MEWC detect
  docker run --env CUDA_VISIBLE_DEVICES="$GPU" --env-file "${params}" --gpus all --interactive --tty --rm --volume "${in_dir}:/images" zaandahl/mewc-detect

  # MEWC snip
  docker run --interactive --tty --rm --env-file "${params}" --volume "${in_dir}:/images" zaandahl/mewc-snip

  # MEWC predict
  docker run --env CUDA_VISIBLE_DEVICES="$GPU" --env-file "${params}" --gpus all --interactive --tty --rm --volume "${in_dir}:/images" --mount type=bind,source="${model}",target=/code/model.h5 --mount type=bind,source="${cl}",target=/code/class_list.yaml zaandahl/mewc-predict

  # MEWC exif
  docker run --interactive --tty --rm --env-file "${params}" --volume "${in_dir}:/images" zaandahl/mewc-exif

  # MEWC box
  docker run --interactive --tty --rm --env-file "${params}" --volume "${in_dir}:/images" zaandahl/mewc-box
}

# Pull the Docker images
docker pull zaandahl/mewc-detect
docker pull zaandahl/mewc-snip
docker pull zaandahl/mewc-predict
docker pull zaandahl/mewc-exif
docker pull zaandahl/mewc-box

# Find directories containing .jpg files, excluding specific names
find "$SERVICE_DIR" -type d -not -path "*/animal/*" -not -path "*/blank/*" -not -path "*/human/*" -not -path "*/snips/*" | while read -r folder; do
  if ls "$folder"/*.jpg 1> /dev/null 2>&1; then
    mewc_script "$folder" "$PARAM_ENV" "$CLASS" "$MODEL"
  fi
done

# Usage example:
# ./mewc_run_service.sh /path/to/example /path/to/params.env /path/to/class_list.yaml /path/to/model.h5 /path/to/gpu
