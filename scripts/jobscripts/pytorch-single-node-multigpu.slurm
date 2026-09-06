#!/bin/bash
#SBATCH --gpus=8
#SBATCH --partition=multigpu
#SBATCH -c 48
#SBATCH -t 01:00:00
#SBATCH -J pytorch-multigpu
#SBATCH -o pytorch-multigpu-%j.out
#
# See docs/07-running-jobs.md. Adjust conda env name, data paths,
# and training args for your project.

echo "$HOME"
source "$HOME/miniconda3/bin/activate" materov

export DATA_DIR=/sw/datasets
export XDG_RUNTIME_DIR=/tmp

env | grep SLURM
env | grep CUDA

cd /sw/user01/data/yolov9

export BATCH_SIZE=64
export EPOCHS=10

python -m torch.distributed.run --nproc-per-node 8 --nnodes 1 train.py \
  --batch ${BATCH_SIZE} --epochs ${EPOCHS} \
  --img 640 --device ${CUDA_VISIBLE_DEVICES} --min-items 0 --close-mosaic 15 \
  --data /sw/datasets/images/ALLFathomNET_images/data.yaml \
  --weights /sw/user01/archive/best3.pt \
  --cfg models/detect/gelan-c.yaml \
  --workers 48 \
  --hyp hyp.scratch-high.yaml
