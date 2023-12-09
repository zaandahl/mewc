# Training and Inference: A Step-by-Step Guide to the Mega Efficient Wildlife Classifier

## Setup the Environment

1. Provision a Nectar A100 GPU cloud instance or use your local GPU machine. Scripts for Nectar cloud setup can be found at [MEWC Infrastructure](https://github.com/zaandahl/mewc-infrastructure).

## Retrieve and Unpack the Dataset

1. Data can be obtained from the [UTAS Datastore](https://rdp.utas.edu.au/metadata/3a2d9dcf-f8fa-4514-aab0-b9d36f5a1983). For this example, training and service data are extracted using tar under `/mnt/mewc-volume/train/` and `/mnt/mewc-volume/predict` respectively.

---

# Training the Tasmanian Wildlife Classifier

## Override Default Configuration as Needed

1. Use environment variables to override the default EN-B0 model to a more powerful EN-V2S model.

   ```bash
   cd /mnt/mewc-volume/train
   vi params.env
   MODEL=EN-V2S
   CLW=512
   LUF=360
   SHAPES=300,300,300
   BATCH_SIZES=128,128,128
   ```

## Pull the Latest Docker Image and Initiate Training

1. Pull the latest Docker image and start the training process.

   ```bash
   docker pull zaandahl/mewc-train
   docker run --env CUDA_VISIBLE_DEVICES=0 --gpus all --env-file params.env \
   --volume /mnt/mewc-volume/train/data:/data zaandahl/mewc-train
   ```

## Retrieve the Output

1. Post-training files are located in `/data/output`: `class_list.yaml` and final model `mewc_model_300px_final.h5`.

---

# Inference Over a Camera Service Using the Trained Model

## Copy Model Training Outputs, Pull Docker Images

1. Copy the model training outputs and pull the necessary Docker images.

   ```bash
   cp ./train/data/output/class_list.yaml ./predict/
   cp ./train/data/output/mewc_model_300px_final.h5 ./predict
   docker pull zaandahl/mewc-detect; docker pull zaandahl/mewc-snip; docker pull zaandahl/mewc-predict; docker pull zaandahl/mewc-exif; docker pull zaandahl/mewc-box
   cd predict
   ```

## Run the Five Stages of the Docker Inference Pipeline

1. Execute the five stages of the Docker inference pipeline on the first camera in the service.

   ```bash
   docker run --env CUDA_VISIBLE_DEVICES=0 --gpus all \
   --volume /mnt/mewc-volume/predict/Service/HR-C15:/images zaandahl/mewc-detect
   docker run --volume /mnt/mewc-volume/predict/Service/HR-C15:/images zaandahl/mewc-snip
   docker run --env CUDA_VISIBLE_DEVICE=0 --env TARGET_SIZE=300 --gpus all \
   --volume /mnt/mewc-volume/predict/Service/HR-C15/:/images \
   --volume /mnt/mewc-volume/predict/mewc_model_300px_final.h5:/code/model.h5 \
   --volume /mnt/mewc-volume/predict/class_list.yaml:/code/class_list.yaml zaandahl/mewc-predict
   docker run --volume /mnt/mewc-volume/predict/Service/HR-C15:/images zaandahl/mewc-exif
   docker run --volume /mnt/mewc-volume/predict/Service/HR-C15:/images zaandahl/mewc-box
   ```

## Repeat for Each Camera

1. Repeat the above step for each camera in the Service Directory.
