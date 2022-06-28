import os
import yaml
import detection.run_detector_batch as run_detector_batch

os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'

def read_yaml(file_path):
    with open(file_path, "r") as f:
        return yaml.safe_load(f)

config = read_yaml('config.yaml')
for conf_key in config.keys():
    if conf_key in os.environ:
        config[conf_key] = os.environ[conf_key]

md_cmd = "python /code/cameratraps/detection/run_detector_batch.py --recursive \
--checkpoint_frequency=" + str(config["CHECKPOINT_FREQ"]) + \
" --threshold=" + str(config["THRESHOLD"]) + \
" /code/" + str(config["MD_MODEL"]) + " " + \
str(config["INPUT_DIR"]) + " " + \
str(config["INPUT_DIR"]) + "/" + str(config["MD_FILE"])

#run_detector_batch.main(["--recursive", "--checkpoint_frequency=100","--threshold=0.01", "/code/md_v4.1.0.pb", "/images", "/images/md_out.json"])
#os.system("python /code/cameratraps/detection/run_detector_batch.py --recursive --checkpoint_frequency=100 --threshold=0.01 /code/md_v4.1.0.pb /images /images/md_out.json")
os.system(md_cmd)