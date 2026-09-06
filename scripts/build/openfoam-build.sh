#!/bin/bash
#SBATCH -c 16
#SBATCH -J openfoam-build
#SBATCH -o openfoam-build-%j.out
#
# Build OpenFOAM v2306. Submit with: sbatch openfoam-build.sh
# See docs/06-openfoam.md.

module load openmpi/4.1.6

cd /sw/apps/OpenFOAM-v2306
source /sw/apps/OpenFOAM-v2306/etc/bashrc
wmake -j 16 -all
