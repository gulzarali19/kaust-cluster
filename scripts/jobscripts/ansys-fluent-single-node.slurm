#!/bin/bash
#SBATCH --ntasks=18
#SBATCH --ntasks-per-node=18
#SBATCH --hint=nomultithread
#SBATCH -J fluent-1node
#SBATCH -o fluent-%j.out
#
# Single-node Fluent run. Tested on c5n.9xlarge with hyperthreading
# disabled. See docs/05-ansys-fluent.md.

module use /sw/modulefiles
module load ansys
module load openmpi

HF=hostfile.txt
rm -f "${HF}"

nodes=$(scontrol show hostnames "$SLURM_JOB_NODELIST")
nodes_array=($nodes)

for (( i=0; i<${SLURM_NNODES}; i++ )); do
  node_id=${nodes_array[$i]}
  srun -n 1 -N 1 -w "${node_id}" ./wrapper.sh >> "${HF}"
done

time fluent -g -t${SLURM_NTASKS} 3ddp -cnf=${HF} -pethernet -cflush -mpi=openmpi -i cavity.in
