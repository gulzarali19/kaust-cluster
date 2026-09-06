# kaust-cluster
Documents for cluster creation

# CFD Cluster on AWS

Runbooks, configs, and job scripts for standing up and operating an
AWS ParallelCluster (SLURM) HPC cluster for CFD workloads (OpenFOAM,
ANSYS Fluent) and GPU/ML workloads (PyTorch), including a FlexLM/ANSYS
license server.

This repo was assembled from the team's internal setup docs. See
[`GAPS_AND_RECOMMENDATIONS.md`](GAPS_AND_RECOMMENDATIONS.md) for a
review of what's missing or worth hardening before this goes further.

## Repo structure

```
.
├── docs/                         Runbooks, one topic per file
│   ├── 00-architecture-overview.md
│   ├── 01-prerequisites.md
│   ├── 02-cluster-creation.md
│   ├── 03-post-cluster-admin-tasks.md
│   ├── 04-license-server-flexlm.md
│   ├── 05-ansys-fluent.md
│   ├── 06-openfoam.md
│   ├── 07-running-jobs.md
│   ├── 08-slurm-accounting.md
│   ├── 09-user-management.md
│   ├── 10-roles-and-roadmap.md
│   └── 11-cluster-journal.md
├── configs/                      ParallelCluster YAML + modulefiles
│   ├── cluster-config-hpc-features.yaml
│   ├── cluster-config-slurm-accounting-example.yaml
│   ├── cluster-config-appendix-a-minimal.yaml
│   ├── secrets.env.example
│   └── modulefiles/ansys/2024R2
├── scripts/
│   ├── setup/                    One-time account & cluster setup
│   ├── build/                    Software build scripts (OpenFOAM)
│   └── jobscripts/               SLURM batch/interactive job scripts
├── SECURITY.md
└── GAPS_AND_RECOMMENDATIONS.md
```

## Quick start

1. Read `docs/01-prerequisites.md` and run the scripts in `scripts/setup/`.
2. Read `docs/02-cluster-creation.md`, pick a config from `configs/`,
   adjust the placeholders (subnet IDs, key names, region), and run
   `pcluster create-cluster`.
3. Read `docs/03-post-cluster-admin-tasks.md` for the manual steps
   needed right after the cluster comes up (license server access,
   per-user env vars, sudoer setup).
4. If you need ANSYS/Fluent or OpenFOAM, follow `docs/05-ansys-fluent.md`
   or `docs/06-openfoam.md`, then submit jobs from `docs/07-running-jobs.md`.
5. For a license server, follow `docs/04-license-server-flexlm.md`.

## Software covered

| Component        | Docs                        |
|-------------------|-----------------------------|
| AWS ParallelCluster / SLURM | `docs/01`–`03` |
| FlexLM / ANSYS license server | `docs/04` |
| ANSYS Fluent | `docs/05` |
| OpenFOAM v2306 | `docs/06` |
| PyTorch (GPU/multi-GPU/multi-node) + JupyterLab + TensorBoard | `docs/07` |
| SLURM accounting (RDS-backed) | `docs/08` |
