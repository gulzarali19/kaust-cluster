#!/bin/bash
#SBATCH -n 8
#SBATCH -J icoFoam-cavity-1node
#SBATCH -o icoFoam-%j.out
#
# Single-node icoFoam cavity tutorial. See docs/06-openfoam.md.

source /sw/apps/OpenFOAM-v2306/etc/bashrc
module load openmpi/4.1.6

cd cavity
blockMesh
decomposePar
srun -n 8 --mpi=pmix icoFoam -parallel
reconstructPar
