# Place at /sw/apps/OpenFOAM-v2306/etc/prefs.sh before building.
# See docs/06-openfoam.md.

export FOAM_INST_DIR="/sw/apps/OpenFOAM-v2306"
export WM_MPLIB=SYSTEMOPENMPI
export MPI_ROOT="/opt/amazon/openmpi"
export WM_COMPILER_TYPE=system
export WM_COMPILER=Gcc
export WM_LABEL_SIZE=32
export WM_NCOMPPROC=16
