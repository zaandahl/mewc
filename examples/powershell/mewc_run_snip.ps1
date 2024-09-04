# Run MEWC-snip on a Service, recursing through all subdirectories that contain image files

param (
  [string]$i = ".\",
  [string]$p = ".\"
)

$SERVICE_DIR = (Resolve-Path -Path $i) | Convert-Path
$PARAM_ENV = (Resolve-Path -Path $p) | Convert-Path

Function MEWC_SCRIPT {
  Param($IN_DIR, $PARAMS)
  Write-Host "Site Directory: $IN_DIR"
  $docker_snip = "docker run --env-file $PARAMS --interactive --tty --rm --volume `"${IN_DIR}:/images`" zaandahl/mewc-snip"
  Invoke-Expression $docker_snip
}

docker pull zaandahl/mewc-snip

$folders = gci $SERVICE_DIR -recurse -force | 
	where-object { $_.PSIsContainer -and ($_.GetFiles().Name -match '.jpg') -and (($_.GetFiles().Count -gt 0)) -and ($_.Name -notmatch '^(animal|blank|human|snips)$') }

$folders | 
	ForEach-Object {
        MEWC_SCRIPT "$($_.FullName)" $PARAM_ENV
	}

# C:\mewc\ps\mewc_run_snip.ps1 -i C:\service -p C:\mewc\model\params.env
