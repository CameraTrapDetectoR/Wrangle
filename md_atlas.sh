#!/bin/bash

#SBATCH --partition=gpu
#SBATCH --qos='normal'
#SBATCH --job-name=wrangle
#SBATCH --account=cameratrapdetector
#SBATCH --mail-user=Amira.Burns@usda.gov
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --time=72:00:00
#SBATCH --nodes=1
#SBATCH --gpus-per-node=1


# run MegaDetector on single GPU node on Atlas
module purge

module load miniconda
source activate cameratraps-detector
set PYTHONPATH=%PYTHONPATH%;/project/cameratrapdetector/datawrangling/cameratraps;/project/cameratrapdetector/datawrangling/ai4eutils;/project/cameratrapdetector/datawrangling/yolov5

module unload miniconda
module load python

cd /project/cameratrapdetector/datawrangling/cameratraps/

model_file = "/project/cameratrapdetector/datawrangling/cameratraps/models/md_v5a.0.0.pt"
image_dir = "/90daydata/cameratrapdetector/datawrangling/"
output_file = "/project/cameratrapdetector/datawrangling/megadetector_output.json"

python detection/run_detector_batch.py --detection_file model_file --image_file image_dir --output_file output_file --output_file_names --recursive --checkpoint_frequency 100mo)N1i%*hT^xrA

