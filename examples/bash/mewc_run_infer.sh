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

# Function to run MEWC classifier inference script
mewc_script() {
  local in_dir=$1
  local params=$2
  local cl=$3
  local model=$4
  docker run --env CUDA_VISIBLE_DEVICES="$GPU" --env-file "${params}" --gpus all --interactive --tty --rm --volume "${in_dir}:/images" --mount type=bind,source="${model}",target=/code/model.h5 --mount type=bind,source="${cl}",target=/code/class_list.yaml zaandahl/mewc-predict
}

# Pull the Docker image
docker pull zaandahl/mewc-predict

# Find directories containing .jpg files, excluding specific names
find "$SERVICE_DIR" -type d -not -path "*/animal/*" -not -path "*/blank/*" -not -path "*/human/*" -not -path "*/snips/*" | while read -r folder; do
  if ls "$folder"/*.jpg 1> /dev/null 2>&1; then
    mewc_script "$folder" "$PARAM_ENV" "$CLASS" "$MODEL"
  fi
done

# Usage example:
# ./mewc_run_infer.sh /path/to/example /path/to/params.env /path/to/class_list.yaml /path/to/model.h5 /path/to/gpu
