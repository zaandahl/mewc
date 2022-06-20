#!/bin/bash
while getopts i: flag
do
    case "${flag}" in
        i) IN_DIR=${OPTARG};;
    esac
done

# check if input directory is missing
if [ -z "$IN_DIR" ]
then
  export IN_DIR=$(pwd)
fi
# check if input directory is valid directory
if [ ! -d "$IN_DIR" ]
then
  echo "ERROR: input directory $IN_DIR does not exist"
  exit
fi
export IN_DIR=$(cd $IN_DIR; pwd)

exec docker pull zaandahl/megadetector_v4:latest
exec docker run --env CUDA_VISIBLE_DEVICES=0 --env-file megadetector.env \
    --gpus all --interactive --tty --rm \
    --volume "$IN_DIR":/images \
    zaandahl/megadetector_v4
