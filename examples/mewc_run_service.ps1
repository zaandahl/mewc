# Run the full MEWC sequence, camera-by-camera, on a service, recursing through all subdirectories that contain image files
param (
  [string]$i = ".\",
  [string]$p = ".\",
  [string]$c = ".\",
  [string]$m = ".\",
  [string]$g = ".\"
)

$SERVICE_DIR = $i | Resolve-Path
$PARAM_ENV = $p | Resolve-Path
$CLASS = $c | Resolve-Path
$EN_MODEL = $m | Resolve-Path

Function MEWC_SCRIPT {
  Param($IN_DIR, $PARAMS, $CL, $MODEL)
  docker run --env CUDA_VISIBLE_DEVICES=$g --env-file ${PARAMS} --gpus all --interactive --tty --rm --volume ''$IN_DIR':/images' zaandahl/mewc-detect
  docker run --interactive --tty --rm --env-file ${PARAMS} --volume ''$IN_DIR':/images' zaandahl/mewc-snip
  docker run --env CUDA_VISIBLE_DEVICES=$g --env-file ${PARAMS} --gpus all --interactive --tty --rm --volume ''$IN_DIR':/images' --mount type=bind,source=${MODEL},target=/code/model.h5 --mount type=bind,source=${CL},target=/code/class_list.yaml zaandahl/mewc-predict
  docker run --interactive --tty --rm --env-file ${PARAMS} --volume ''$IN_DIR':/images' zaandahl/mewc-exif
  docker run --interactive --tty --rm --env-file ${PARAMS} --volume ''$IN_DIR':/images' zaandahl/mewc-box
}

docker pull zaandahl/mewc-detect
docker pull zaandahl/mewc-snip
docker pull zaandahl/mewc-predict
docker pull zaandahl/mewc-exif
docker pull zaandahl/mewc-box

$folders = gci $SERVICE_DIR -recurse -force | 
	where-object { $_.PSIsContainer -and ($_.GetFiles().Name -imatch '.jpg') -and (($_.GetFiles().Count -gt 0)) -and ($_.Name -notmatch '^(animal|blank|human|snips)$') }

$folders | 
	ForEach-Object {
        MEWC_SCRIPT "$($_.FullName)" $PARAM_ENV $CLASS $EN_MODEL
	}

# Example call, for GPU-0, with custom classifier model: 
# C:\mewc\ps\mewc_run_service.ps1 -i C:\example -p C:\mewc\model\params.env -c C:\mewc\yaml\class_list.yaml -m C:\mewc\model\my_classifier_model.h5 -g 0 
