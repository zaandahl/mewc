# Run MegaDetector on a directory
param (
  [string]$i = ".\"
)
$IN_DIR = $i | Resolve-Path

docker pull zaandahl/megadetector_v4:latest
docker run --env CUDA_VISIBLE_DEVICES=0 --env-file megadetector.env --gpus all --interactive --tty --rm --volume ''$IN_DIR':/images' zaandahl/megadetector_v4
