# ANSYS (Fluent) on the cluster

## Installation

1. Download source packages from the
   [ANSYS current release page](https://download.ansys.com/Current%20Release),
   expanding **Primary Packages**. Don't download the GUI installer —
   this install runs silent/headless.
2. Copy the tarballs to the head node's `/sw/src` and untar (e.g.
   `FLUIDSTRUCTURE.tgz`).
3. Install, pointing at the license server (`<port>:<li-port>:<host>`):

   ```bash
   ./INSTALL -silent -install_dir /sw/ansys_install \
     -licserverinfo 2325:1055:ip-10-0-26-35.ec2.internal
   ```

## Post-installation: test the license connection

```bash
./ansys_install/v242/licensingclient/linx64/lmutil lmstat -c 1055@10.0.26.35 -a
```

> If `lmutil` reports "No such file or directory" on head or compute
> nodes (seen on Ubuntu 20.04/22.04), the fix is the same missing
> library symlink as the license server itself:
>
> ```bash
> sudo ln -s /lib64/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
> ```

## Modulefile

Create `/sw/modulefiles/ansys/2024R2` — full contents at
[`../configs/modulefiles/ansys/2024R2`](../configs/modulefiles/ansys/2024R2).
Key environment variables it sets:

```tcl
setenv ANSYS_ROOT      /sw/ansys_install
setenv AWPROOTDIR       $ANSYS_ROOT/v242
setenv ANSYSLI_SERVERS  2325@ip-10-0-26-35.ec2.internal
setenv ANSYSLMD_LICENSE_FILE 1055@ip-10-0-26-35.ec2.internal
```

Use it:

```bash
module use /sw/modulefiles
module load ansys
lmutil lmstat -a
```

## Running Fluent jobs

Tests were done on a 2-node cluster of `c5n.9xlarge` with
hyperthreading disabled. Job scripts build a Fluent-style hostfile
(`hostname:slots`) from the SLURM node list, then invoke `fluent`
directly (not via `srun`/`mpirun` — Fluent manages its own MPI launch).

- Single node: [`../scripts/jobscripts/ansys-fluent-single-node.slurm`](../scripts/jobscripts/ansys-fluent-single-node.slurm)
- Multi node: [`../scripts/jobscripts/ansys-fluent-multi-node.slurm`](../scripts/jobscripts/ansys-fluent-multi-node.slurm)
- Hostfile helper: [`../scripts/jobscripts/wrapper.sh`](../scripts/jobscripts/wrapper.sh)

Both scripts load the `ansys` and `openmpi` modules, build
`hostfile.txt` via `wrapper.sh`, then run e.g.:

```bash
fluent -g -t${SLURM_NTASKS} 3ddp -cnf=${HF} -pdefault -cflush -mpi=openmpi -i cavity.in
```

Single-node runs use `-pethernet`; multi-node runs use `-pdefault`.

A full sample run transcript (license connect, node spawn, per-core
mapping, output) is worth keeping as a reference for "what a healthy
run looks like" when troubleshooting — see
`../GAPS_AND_RECOMMENDATIONS.md` for a suggestion on where to file
that.
