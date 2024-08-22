# Training and Inference: A Step-by-Step Guide to the Mega Efficient Wildlife Classifier

## Setup the Environment

1. Provision a cloud instance with an A100 GPU, such as those available through the Nectar Cloud for Australian academics or via global providers like AWS, or use your local GPU machine. Scripts for Nectar cloud setup can be found at [MEWC Infrastructure](https://github.com/zaandahl/mewc-infrastructure).

## A Note About Running Docker as Root
By default the Docker daemon always runs as the root user. If you are using the Nectar cloud, this is not a problem as you can use the following command to become root:

```bash
$ sudo su - root
```

Alternatively you can run the Docker containers as the ubuntu user by prefixing the following command to each Docker run command:

```bash
$ docker run --user $(id -u ubuntu):$(id -g ubuntu) --env MPLCONFIGDIR=/tmp/matplotlib
```

The MPLCONFIGDIR environment variable is required to prevent a warning message from being displayed when running the Docker containers as the ubuntu user. If you choose to run as the ubuntu user all the files created by the containers will be owned by ubuntu and you shouldn't run into any permission issues.

## Retrieve and Unpack the Dataset

1. Data can be obtained from the [UTAS Datastore](https://rdp.utas.edu.au/metadata/3a2d9dcf-f8fa-4514-aab0-b9d36f5a1983). For this example, training and service data are extracted using tar under `/mnt/mewc-volume/train/` and `/mnt/mewc-volume/predict` respectively.

---

# Training the Tasmanian Wildlife Classifier

## Override Default Configuration as Needed

1. Use environment variables to override default options for fast training with the EN-B0 model.

   ```bash
   cd /mnt/mewc-volume/train
   vi lite.env
   CUDA_VISIBLE_DEVICES=0
   MODEL=ENB0
   SAVEFILE=vignette
   SEED=42
   PROG_TOT_EPOCH=40
   BATCH_SIZE=16
   CLASS_SAMPLES_DEFAULT=200
   ```

   Alternatively if you have some time to complete training you can use a more powerful model and get better training accuracy. You may want to use the Unix command [screen](https://en.wikipedia.org/wiki/GNU_Screen) if you are working on a virtual machine to keep your training session running in the background. 

   ```bash
   cd /mnt/mewc-volume/train
   vi hefty.env
   CUDA_VISIBLE_DEVICES=0
   MODEL=ENS
   SAVEFILE=vignette
   SEED=42
   PROG_TOT_EPOCH=60
   BATCH_SIZE=32
   CLASS_SAMPLES_DEFAULT=3000
   ``` 

## Pull the Latest Docker Image and Initiate Training

1. Pull the latest Docker image and start the training process.

   ```bash
   docker pull zaandahl/mewc-train
   docker run --gpus all --env-file lite.env \
   --volume /mnt/mewc-volume/train/data:/data zaandahl/mewc-train
   ```

Using the settings defined in `lite.env` should allow training to complete in under a half an hour and achieve a little above 97% classification accuracy. You can push the accuracy above 99.5% by using the `hefty.env` settings shown above but it will take a bit longer. After training you will get a classification report. 

## Retrieve the Output

1. Post-training files are located in `/data/output/vignette/ENB0/` 

 - `vignette_ENB0_best.keras` : the best performing model save file
 - `vignette_ENB0_final.keras` : the final model save file (may be overfit)
 - `vignette_class_map.yaml` : model class mapping in the format `class name: model int`
 - `confusion_matrix.png` : a confusion matrix from the training process

---

# Inference Over a Camera Service Using the Trained Model

## Copy Model Training Outputs, Pull Docker Images

1. Copy the model training outputs and pull the necessary Docker images.

   ```bash
   cp ./train/data/output/vignette/ENB0/vignette_class_map.yaml ./predict/
   cp ./train/data/output/vignette/ENB0/vignette_ENB0_best.keras ./predict/
   docker pull zaandahl/mewc-detect; docker pull zaandahl/mewc-snip; docker pull zaandahl/mewc-predict; docker pull zaandahl/mewc-exif; docker pull zaandahl/mewc-box
   cd predict
   ```

## Run the Five Stages of the Docker Inference Pipeline

1. Execute the five stages of the Docker inference pipeline on the first camera in the service. Note that the file name you give to your configuration parameters is arbitrary and passed to the docker command.

   ```bash
   vi settings.env
   CUDA_VISIBLE_DEVICES=0
   MODEL=ENB0
   BATCH_SIZE=16
   ```

   - First run `mewc-detect` to identify animals in the images and define bounding boxes around them.

   ```bash
   docker run --env-file settings.env --gpus all \
   --volume /mnt/mewc-volume/predict/Service/HR-C15:/images zaandahl/mewc-detect
   ```

   - Next run `mewc-snip` to create snip files which just contain the animals of interest (losing the background).

   ```bash
   docker run --volume /mnt/mewc-volume/predict/Service/HR-C15:/images zaandahl/mewc-snip
   ```

   - Now run `mewc-predict` to perform inference on the images.

   ```bash
   docker run --env-file settings.env --gpus all \
   --volume /mnt/mewc-volume/predict/Service/HR-C15/:/images \
   --volume /mnt/mewc-volume/predict/vignette_ENB0_best.keras:/code/model.keras \
   --volume /mnt/mewc-volume/predict/vignette_class_map.yaml:/code/class_map.yaml zaandahl/mewc-predict
   ```

   - You can use `mewc-exif` to embed class information into the exif data of the images

   ```bash
   docker run --volume /mnt/mewc-volume/predict/Service/HR-C15:/images zaandahl/mewc-exif
   ```

   - Lastly, run `mewc-box` to draw red bounding boxes around the animals in the images and sort the images into subfolders.

   ```bash
   docker run --volume /mnt/mewc-volume/predict/Service/HR-C15:/images zaandahl/mewc-box
   ```

## Repeat for Each Camera

1. Repeat the above step for each camera in the Service Directory.
