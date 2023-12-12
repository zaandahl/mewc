#!/bin/bash

# Default values for input and parameter directories
SERVICE_DIR="${1:-.}"
PARAM_ENV="${2:-.}"

# Resolve absolute paths
SERVICE_DIR=$(realpath "$SERVICE_DIR")
PARAM_ENV=$(realpath "$PARAM_ENV")

# Function to run MEWC snip script
mewc_script() {
  local in_dir=$1
  local params=$2
  docker run --interactive --tty --rm --env-file "${params}" --volume "${in_dir}:/images" zaandahl/mewc-snip
}

# Pull the Docker image
docker pull zaandahl/mewc-snip

# Find directories containing .jpg files, excluding specific names
find "$SERVICE_DIR" -type d -not -path "*/animal/*" -not -path "*/blank/*" -not -path "*/human/*" -not -path "*/snips/*" | while read -r folder; do
  if ls "$folder"/*.jpg 1> /dev/null 2>&1; then
    mewc_script "$folder" "$PARAM_ENV"
  fi
done

# Usage example:
# ./mewc_run_snip.sh /path/to/example /path/to/params.env
