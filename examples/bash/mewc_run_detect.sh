#!/bin/bash

# Default values for input, parameter, and GPU directories
SERVICE_DIR="${1:-.}"
PARAM_ENV="${2:-.}"
GPU="${3:-0}"

# Resolve absolute paths
SERVICE_DIR=$(realpath "$SERVICE_DIR")
PARAM_ENV=$(realpath "$PARAM_ENV")

# Function to run MEWC detect script
mewc_script() {
  local in_dir=$1
  local params=$2
  docker run --env CUDA_VISIBLE_DEVICES="$GPU" --env-file "${params}" --gpus all --interactive --tty --rm --volume "${in_dir}:/images" zaandahl/mewc-detect
}

# Pull the Docker image
docker pull zaandahl/mewc-detect

# Find directories containing .jpg files, excluding specific names
find "$SERVICE_DIR" -type d -not -path "*/animal/*" -not -path "*/blank/*" -not -path "*/human/*" -not -path "*/snips/*" | while read -r folder; do
  if ls "$folder"/*.jpg 1> /dev/null 2>&1; then
    mewc_script "$folder" "$PARAM_ENV"
  fi
done

# Usage example:
# ./mewc_run_detect.sh /path/to/example /path/to/params.env /path/to/gpu
