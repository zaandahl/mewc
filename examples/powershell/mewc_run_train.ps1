# PowerShell call example:
# In this example, the system has a single GPU (CUDA_VISIBLE_DEVICES=0) and the host directory C:\mewc_train\ is mounted to the container directory /data
# In this case, training data should be placed in the host directory, e.g., C:\mewc_train\train and the test data in C:\mewc_train\test
# The training and test data (pre-sorted snips) should be in the format of a directory with named subdirectories for each class containing their images

param (
  [string]$d = ".\",
  [string]$p = ".\",
  [string]$g = ".\"
)

$DATA_DIR = (Resolve-Path -Path $d) | Convert-Path
$PARAM_ENV = (Resolve-Path -Path $p) | Convert-Path

docker pull zaandahl/mewc-train
docker run --env CUDA_VISIBLE_DEVICES=$g --gpus all --env-file $PARAM_ENV --volume ${DATA_DIR}:/data zaandahl/mewc-train

# Example call, for GPU-0: 
# C:\mewc\ps\mewc_run_train.ps1 -d C:\mewc_train -p C:\mewc\env\train_params.env -g 0

