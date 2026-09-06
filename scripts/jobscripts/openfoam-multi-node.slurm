#!/bin/bash
#SBATCH -n 16
#SBATCH -N 2
#SBATCH -J icoFoam-cavity-2node
#SBATCH -o icoFoam-%j.out
#
# Multi-node icoFoam cavity tutorial. See docs/06-openfoam.md.

source /sw/apps/OpenFOAM-v2306/etc/bashrc
module load openmpi/4.1.6

cd cavity
blockMesh
decomposePar
srun -n 16 -N 2 --mpi=pmix icoFoam -parallel
reconstructPar
