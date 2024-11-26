#!/bin/bash

# Default values for input, parameter, class list, and model directories
SERVICE_DIR="${1:-.}"
PARAM_ENV="${2:-.}"
CLASS="${3:-.}"
MODEL="${4:-.}"

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

  echo "Starting full MEWC sequence for folder: $in_dir with params: $params, class map: $cl, and model: $model"

  # MEWC detect
  echo "Running MEWC detect..."
  docker run --env CUDA_VISIBLE_DEVICES="0" --env-file "${params}" --gpus all --interactive --rm --volume "${in_dir}:/images" zaandahl/mewc-detect

  # MEWC snip
  echo "Running MEWC snip..."
  docker run --env CUDA_VISIBLE_DEVICES="0" --env-file "${params}" --gpus all --interactive --rm --volume "${in_dir}:/images" zaandahl/mewc-snip

  # MEWC predict
  echo "Running MEWC predict..."
  local start_time=$(date +%s)  # Record start time
  docker run --env CUDA_VISIBLE_DEVICES="0" --env-file "${params}" --gpus all --interactive --rm --volume "${in_dir}:/images" \
      --mount type=bind,source="${model}",target=/code/model.keras \
      --mount type=bind,source="${cl}",target=/code/class_map.yaml \
      zaandahl/mewc-predict
  local end_time=$(date +%s)  # Record end time
  local elapsed_time=$((end_time - start_time))
  echo "MEWC predict completed in ${elapsed_time} seconds."

  # MEWC exif
  echo "Running MEWC exif..."
  docker run --env CUDA_VISIBLE_DEVICES="0" --env-file "${params}" --gpus all --interactive --rm --volume "${in_dir}:/images" zaandahl/mewc-exif

  # MEWC box
  echo "Running MEWC box..."
  docker run --env CUDA_VISIBLE_DEVICES="0" --env-file "${params}" --gpus all --interactive --rm --volume "${in_dir}:/images" zaandahl/mewc-box

  echo "Finished full MEWC sequence for folder: $in_dir"
}

# Pull the Docker images
echo "Pulling Docker images..."
docker pull zaandahl/mewc-detect
docker pull zaandahl/mewc-snip
docker pull zaandahl/mewc-predict
docker pull zaandahl/mewc-exif
docker pull zaandahl/mewc-box

# Collect directories into an array
echo "Finding directories containing .jpg files..."
folders=($(find "$SERVICE_DIR" -type d -not -path "*/animal/*" -not -path "*/blank/*" -not -path "*/human/*" -not -path "*/snips/*"))

# Iterate over the collected directories
for folder in "${folders[@]}"; do
    if ls "$folder"/*.[jJ][pP][gG] 1> /dev/null 2>&1; then
        mewc_script "$folder" "$PARAM_ENV" "$CLASS" "$MODEL"
    else
        echo "Skipping $folder (no .jpg files found)"
    fi
done
