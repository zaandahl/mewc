# Run MEWC-classifier-inference on a Service, recursing through all subdirectories that contain image files

param (
  [string]$i = ".\",
  [string]$p = ".\",
  [string]$c = ".\",
  [string]$m = ".\",
  [string]$g = ".\"
)

$SERVICE_DIR = (Resolve-Path -Path $i) | Convert-Path
$PARAM_ENV = (Resolve-Path -Path $p) | Convert-Path
$CLASS = (Resolve-Path -Path $c) | Convert-Path
$MEWC_MODEL = (Resolve-Path -Path $m) | Convert-Path

Function MEWC_SCRIPT {
  Param($IN_DIR, $PARAMS, $CL, $MODEL)
  $docker_predict = "docker run --env CUDA_VISIBLE_DEVICES=$g --env-file $PARAMS --gpus all --interactive --tty --rm --volume `"${IN_DIR}:/images`" --mount type=bind,source=$MODEL,target=/code/model.keras --mount type=bind,source=$CL,target=/code/class_map.yaml zaandahl/mewc-predict"
  Invoke-Expression $docker_predict
}

docker run --env CUDA_VISIBLE_DEVICES=0 --gpus all --env-file params.env --volume /mnt/mewc-volume/train/data:/data zaandahl/mewc-train

$folders = gci $SERVICE_DIR -recurse -force | 
  where-object { $_.PSIsContainer -and ($_.GetFiles().Name -imatch '.jpg') -and (($_.GetFiles().Count -gt 0)) -and ($_.Name -notmatch '^(animal|blank|human|snips)$') }

$folders | 
	ForEach-Object {
        MEWC_SCRIPT "$($_.FullName)" $PARAM_ENV $CLASS $MEWC_MODEL
	}

# Example call, for GPU-0: 
# C:\mewc\ps\mewc_run_train.ps1 -i C:\service -p C:\mewc\model\params.env -c C:\mewc\yaml\class_map.yaml -m C:\mewc\model\ens_mewc_case_study.keras -g 0
