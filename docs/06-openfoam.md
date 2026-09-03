# OpenFOAM v2306

## Download source

```bash
cd /sw
mkdir -p src build apps
cd src

wget https://dl.openfoam.com/source/v2306/OpenFOAM-v2306.tgz
wget https://dl.openfoam.com/source/v2306/ThirdParty-v2306.tgz

tar xvf OpenFOAM-v2306.tgz
tar xvf ThirdParty-v2306.tgz
```

> **Fixed from source doc**: the original ThirdParty URL mixed v2312
> and v2306 path segments (`.../v2312/ThirdParty-v2312.tgz` with a
> literal `v2306` spliced in) — that link would 404 or fetch the
> wrong version. The URL above is corrected to the matching v2306
> ThirdParty tarball; verify against the
> [OpenFOAM download page](https://www.openfoam.com/download/source)
> before relying on it, since the exact filename layout is worth
> double-checking against the live page.

## Configure

```bash
module load openmpi/4.1.6
cd /sw/apps/OpenFOAM-v2306/
touch etc/prefs.sh
```

`etc/prefs.sh` contents — full file at
[`../scripts/build/openfoam-prefs.sh`](../scripts/build/openfoam-prefs.sh):

```bash
export FOAM_INST_DIR="/sw/apps/OpenFOAM-v2306"
export WM_MPLIB=SYSTEMOPENMPI
export MPI_ROOT="/opt/amazon/openmpi"
export WM_COMPILER_TYPE=system
export WM_COMPILER=Gcc
export WM_LABEL_SIZE=32
export WM_NCOMPPROC=16
```

## Build

Submit as a SLURM job:
[`../scripts/build/openfoam-build.sh`](../scripts/build/openfoam-build.sh)

```bash
#!/bin/bash
#SBATCH -c 16
cd /sw/apps/OpenFOAM-v2306
source /sw/apps/OpenFOAM-v2306/etc/bashrc
wmake -j 16 -all
```

## Getting a prebuilt copy onto a new cluster

If `/sw` isn't already populated (e.g. new cluster, no EFS retention
from a prior one):

```bash
aws s3 cp s3://rts-sw-backup/of_sw.tar .
tar xvf of_sw.tar -C /sw --strip-components=1
```

## Running jobs

```bash
cd /scratch/<your-user>
cp -r /sw/apps/OpenFOAM-v2306/tutorials/incompressible/icoFoam/cavity/cavity .
```

- Single node: [`../scripts/jobscripts/openfoam-single-node.slurm`](../scripts/jobscripts/openfoam-single-node.slurm)
- Multi node: [`../scripts/jobscripts/openfoam-multi-node.slurm`](../scripts/jobscripts/openfoam-multi-node.slurm)

Both follow: `blockMesh` → `decomposePar` → `srun ... icoFoam -parallel`
→ `reconstructPar`.
