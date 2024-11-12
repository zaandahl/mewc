# Run MegaDetector on a Service, recursing through all subdirectories that contain image files
param (
  [string]$i = ".\",
  [string]$p = ".\",
  [string]$g = ".\"
)

$SERVICE_DIR = (Resolve-Path -Path $i) | Convert-Path
$PARAM_ENV = (Resolve-Path -Path $p) | Convert-Path

Function MEWC_SCRIPT {
  Param($IN_DIR, $PARAMS)
  Write-Host "Site Directory: $IN_DIR"
  $docker_detect = "docker run --env CUDA_VISIBLE_DEVICES=$g --env-file $PARAMS --gpus all --interactive --tty --rm --volume `"${IN_DIR}:/images`" zaandahl/mewc-detect"
  Invoke-Expression $docker_detect
}

docker pull zaandahl/mewc-detect

$folders = Get-ChildItem $SERVICE_DIR -Recurse -Force | 
  Where-Object { $_.PSIsContainer -and ($_.GetFiles().Name -imatch '\.jpg$') -and ($_.GetFiles().Count -gt 0) -and ($_.Name -notmatch '^(animal|blank|human|snips)$') }

$folders | ForEach-Object {
    MEWC_SCRIPT "$($_.FullName)" $PARAM_ENV
}

# Example call: 
# C:\mewc\ps\mewc_run_detect.ps1 -i C:\service -p C:\mewc\env\params.env -g 0 
