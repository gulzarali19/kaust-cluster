#!/bin/bash
#SBATCH --gpus=1
#SBATCH -c 8
#SBATCH -t 1:0:0
#SBATCH -J pytorch-1gpu
#SBATCH -o pytorch-1gpu-%j.out
#
# See docs/07-running-jobs.md. Adjust conda env name, data paths,
# and training args for your project.

echo "$HOME"
source "$HOME/miniconda3/bin/activate" materov

export DATA_DIR=/sw/datasets
export XDG_RUNTIME_DIR=/tmp

cd /sw/user01/data/yolov9

python train.py \
  --batch -1 --epochs 100 --img 640 --device 0 --min-items 0 --close-mosaic 15 \
  --data /sw/datasets/images/ALLFathomNET_images/data.yaml \
  --weights /sw/user01/archive/best1.pt \
  --cfg models/detect/gelan-c.yaml \
  --workers 8 \
  --hyp hyp.scratch-high.yaml
