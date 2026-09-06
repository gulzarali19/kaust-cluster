#!/bin/bash
#SBATCH --gpus=1
#SBATCH -c 4
#SBATCH -t 01:0:0
#SBATCH -J jupyterlab
#SBATCH -o jupyterlab-%j.out
#
# Interactive JupyterLab on a compute node. See docs/07-running-jobs.md.
# Submit with: sbatch jupyterlab.slurm, then read the .out file for
# the SSH tunnel command and the JupyterLab URL.

echo "$HOME"
source "$HOME/miniconda3/bin/activate" materov

export DATA_DIR=/sw/datasets
export XDG_RUNTIME_DIR=/tmp

node=$(echo $(hostname -I))
user=${USER}
submit_host=${SLURM_SUBMIT_HOST}

port=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
tb_port=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
nv_port=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')

echo "${node} pinned to port ${port} on ${submit_host}"

# print tunneling instructions
echo -e "
${node} pinned to port ${port} on ${submit_host}

To connect to the compute node ${node} running your jupyter notebook
server, run this command in a new terminal on your workstation/laptop
(replace the login-node address with your cluster's):

ssh -L ${port}:${node}:${port} -L ${tb_port}:${node}:${tb_port} ${user}@<login-node-address>

Copy the link printed below by the jupyter server and replace the
node name with 'localhost' before pasting it into your browser.
" >&2

# launch jupyter server
jupyter-lab --no-browser --port=${port} --port-retries=0 --ip=${node} \
  --NotebookApp.token='' --NotebookApp.password=''
