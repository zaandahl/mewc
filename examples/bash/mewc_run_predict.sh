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

# Function to run MEWC classifier inference script
mewc_script() {
  local in_dir=$1
  local params=$2
  local cl=$3
  local model=$4

  # Check if CLASS and MODEL files are provided
  if [[ ! -f "$cl" || ! -f "$model" ]]; then
    echo "Error: Class map file ($cl) or model file ($model) not found. Skipping $in_dir."
    return 1
  fi

  echo "Starting prediction for folder: $in_dir with params: $params, class map: $cl, and model: $model"
  local start_time=$(date +%s)  # Record start time
  docker run --env CUDA_VISIBLE_DEVICES="0" --env-file "${params}" --gpus all --interactive --rm --volume "${in_dir}:/images" \
      --mount type=bind,source="${model}",target=/code/model.keras \
      --mount type=bind,source="${cl}",target=/code/class_map.yaml \
      zaandahl/mewc-predict
  local end_time=$(date +%s)  # Record end time
  local elapsed_time=$((end_time - start_time))
  echo "MEWC predict completed in ${elapsed_time} seconds."
}

# Pull the Docker image
docker pull zaandahl/mewc-predict

# Collect directories into an array
folders=($(find "$SERVICE_DIR" -type d -not -path "*/animal/*" -not -path "*/blank/*" -not -path "*/human/*" -not -path "*/snips/*"))

# Iterate over the collected directories
for folder in "${folders[@]}"; do
    if [ -d "$folder/snips" ] && [ -f "$folder/md_out.json" ]; then
        mewc_script "$folder" "$PARAM_ENV" "$CLASS" "$MODEL"
    else
        echo "Skipping $folder (missing 'snips' subfolder or 'md_out.json' file)"
    fi
done
