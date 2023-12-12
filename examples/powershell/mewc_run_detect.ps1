# Run MEWC detect on a service, recursing through all subdirectories that contain image files

param (
  [string]$i = ".\",
  [string]$p = ".\",
  [string]$g = ".\"
)

$SERVICE_DIR = $i | Resolve-Path
$PARAM_ENV = $p | Resolve-Path

Function MEWC_SCRIPT {
  Param($IN_DIR, $PARAMS)
  docker run --env CUDA_VISIBLE_DEVICES=$g --env-file ${PARAMS} --gpus all --interactive --tty --rm --volume ''$IN_DIR':/images' zaandahl/mewc-detect
}

docker pull zaandahl/mewc-detect

$folders = gci $SERVICE_DIR -recurse -force | 
  where-object { $_.PSIsContainer -and ($_.GetFiles().Name -match '.jpg') -and (($_.GetFiles().Count -gt 0)) -and ($_.Name -notmatch '^(animal|blank|human|snips)$') }

$folders | 
	ForEach-Object {
        MEWC_SCRIPT "$($_.FullName)" $PARAM_ENV
	}

# Example call:
# C:\mewc\ps\mewc_run_detect.ps1 -i C:\example -p C:\mewc\model\params.env -g 0
