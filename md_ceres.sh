#!/bin/bash

#SBATCH --partition=medium
#SBATCH --job-name='wrangle'
#SBATCH --mail-user=Amira.Burns@usda.gov
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=96  # 48 processor core(s) per node X 2 threads per core


# run MegaDetector on multiple CPU cores on Ceres
module purge

module load miniconda
source activate cameratraps-detector


module unload miniconda
module load python_3

cd /project/cameratrapdetector/datawrangling/cameratraps/

model_file = "/project/cameratrapdetector/datawrangling/cameratraps/models/md_v5a.0.0.pt"
image_dir = "/90daydata/cameratrapdetector/datawrangling/"
output_file = "/project/cameratrapdetector/datawrangling/megadetector_output.json"

python detection/run_detector_batch.py --detection_file model_file --image_file image_dir --confidence_threshold 0.1 --n_cores 96 --output_file output_file --output_file_names --recursive --checkpoint_frequency 100

