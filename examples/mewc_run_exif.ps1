# Run MEWC exif metadata writer on a service, recursing through all subdirectories that contain image files

param (
  [string]$i = ".\",
  [string]$p = ".\"
)

$SERVICE_DIR = $i | Resolve-Path
$PARAM_ENV = $p | Resolve-Path

Function MEWC_SCRIPT {
  Param($IN_DIR, $PARAMS)
  docker run --interactive --tty --rm --env-file ${PARAMS} --volume ''$IN_DIR':/images' zaandahl/mewc-exif
  #docker run --interactive --tty --rm --env-file ${PARAMS} --volume ''$IN_DIR':/images' zaandahl/mewc-exif:1.0.9
}

docker pull zaandahl/mewc-exif

$folders = gci $SERVICE_DIR -recurse -force | 
	where-object { $_.PSIsContainer -and ($_.GetFiles().Name -imatch '.jpg') -and (($_.GetFiles().Count -gt 0)) -and ($_.Name -notmatch '^(animal|blank|human|snips)$') }

$folders | 
	ForEach-Object {
        MEWC_SCRIPT "$($_.FullName)" $PARAM_ENV
	}

# Example call:
# C:\mewc\ps\mewc_run_exif.ps1 -i C:\example -p C:\mewc\model\params.env
