# Run MEWC red-box writer and folder sort on a service, recursing through all subdirectories that contain image files

param (
  [string]$i = ".\",
  [string]$p = ".\"
)

$SERVICE_DIR = $i | Resolve-Path
$PARAM_ENV = $p | Resolve-Path

Function MEWC_SCRIPT {
  Param($IN_DIR, $PARAMS)
  docker run --interactive --tty --rm --env-file ${PARAMS} --volume ''$IN_DIR':/images' zaandahl/mewc-box
  #docker run --interactive --tty --rm --env-file ${PARAMS} --volume ''$IN_DIR':/images' zaandahl/mewc-box:1.0.2
}

docker pull zaandahl/mewc-box

$folders = gci $SERVICE_DIR -recurse -force | 
	where-object { $_.PSIsContainer -and ($_.GetFiles().Name -imatch '.jpg') -and (($_.GetFiles().Count -gt 0)) -and ($_.Name -notmatch '^(animal|blank|human|snips)$') }

$folders | 
    ForEach-Object {
        MEWC_SCRIPT "$($_.FullName)" $PARAM_ENV
	}

# Example call:
# C:\mewc\ps\mewc_run_box.ps1 -i C:\example -p C:\mewc\model\params.env
