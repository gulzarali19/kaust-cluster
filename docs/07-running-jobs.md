# Running GPU / ML jobs

## Manually creating a local user (when not using Active Directory)

```bash
sudo groupadd -g 10000 supplement_group
sudo useradd -G supplement_group -s /bin/bash -U user01 -m

# allow password auth if needed
sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo service sshd restart

sudo passwd user01
```

Delete a user:

```bash
sudo deluser user01
```

## Batch jobs

### PyTorch — single GPU

[`../scripts/jobscripts/pytorch-single-gpu.slurm`](../scripts/jobscripts/pytorch-single-gpu.slurm)

```bash
#!/bin/bash
#SBATCH --gpus=1
#SBATCH -c 8
#SBATCH -t 1:0:0

source $HOME/miniconda3/bin/activate materov
python train.py --batch -1 --epochs 100 --img 640 --device 0 ...
```

### PyTorch — single node, multi-GPU

[`../scripts/jobscripts/pytorch-single-node-multigpu.slurm`](../scripts/jobscripts/pytorch-single-node-multigpu.slurm)

```bash
#!/bin/bash
#SBATCH --gpus=8
#SBATCH --partition=multigpu
#SBATCH -c 48
#SBATCH -t 01:00:00

source $HOME/miniconda3/bin/activate materov
python -m torch.distributed.run --nproc-per-node 8 --nnodes 1 train.py ...
```

### PyTorch — multi-node, multi-GPU

**Not documented in the source material** — the original doc's table
of contents lists this as its own section, but the section itself
was empty. This needs to be written (likely `torchrun` with
`--nnodes`, `--rdzv_backend=c10d`, and a rendezvous endpoint derived
from `SLURM_JOB_NODELIST`, similar to the JupyterLab script's approach
of parsing `scontrol show hostnames`). See
`../GAPS_AND_RECOMMENDATIONS.md`.

## Interactive jobs

### JupyterLab

[`../scripts/jobscripts/jupyterlab.slurm`](../scripts/jobscripts/jupyterlab.slurm)

Picks free ports, launches JupyterLab bound to the compute node's IP,
and prints the SSH tunnel command to run from your laptop:

```bash
ssh -L ${port}:${node}:${port} -L ${tb_port}:${node}:${tb_port} ${user}@<login-node-address>
```

Then open the JupyterLab URL it prints, replacing the compute node
name with `localhost`.

> The script also allocates `nv_port` (presumably for a
> nvidia-smi/dashboard tunnel) but doesn't appear to use it anywhere —
> worth checking if that's leftover or intentionally reserved for
> something not shown here.

### TensorBoard

```bash
tensorboard --port=10010 --bind_all --logdir ${PWD}/exp19
```

Tunnel it the same way as JupyterLab (`tb_port` in the JupyterLab
script is already reserved for this).
