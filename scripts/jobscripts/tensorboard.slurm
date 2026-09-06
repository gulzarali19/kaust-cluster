#!/bin/bash
#SBATCH -c 2
#SBATCH -t 01:0:0
#SBATCH -J tensorboard
#SBATCH -o tensorboard-%j.out
#
# Run alongside a training job on the same node, or standalone
# pointed at a shared logdir. Tunnel with the tb_port from
# jupyterlab.slurm if launched together, or open its own tunnel.
# See docs/07-running-jobs.md.

LOGDIR="${1:-${PWD}/exp19}"

tensorboard --port=10010 --bind_all --logdir "${LOGDIR}"
