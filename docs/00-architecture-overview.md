# Architecture overview

## What this cluster is

An AWS ParallelCluster deployment running SLURM, sized for CFD
(OpenFOAM, ANSYS Fluent) and GPU/ML (PyTorch) workloads, plus a
separate FlexLM/ANSYS license server instance.

## Components

- **Head node** — login/scheduler node. Runs SLURM controller, holds
  `/sw` (shared software) and, depending on config, `/home`.
- **Compute queues** — SLURM partitions backed by EC2 Auto Scaling
  (spot or on-demand), scaling 0→N nodes on demand.
- **Shared storage**:
  - `FsxLustre` mounted at `/workspace` — high-speed scratch for job
    I/O (deleted with the cluster).
  - `Efs` mounted at `/sw` — persistent application/software tree
    (retained even if the cluster is deleted, so software only needs
    to be built/installed once).
- **License server** — a separate, persistent EC2 instance (outside
  the cluster's own lifecycle) running FlexLM + the ANSYS license
  manager, reachable from head + compute node security groups.
- **SLURM accounting DB** (optional) — RDS-backed, added via a
  separate CloudFormation stack, referenced from the cluster config's
  `SlurmSettings.Database`.

## Lifecycle

1. One-time: AWS CLI + `pcluster` tooling, SSH key, license server.
2. Per-cluster: `pcluster create-cluster` → post-creation admin tasks
   (license server security group rules, custom env vars, sudoers) →
   hydrate `/sw` from S3 backup (if not using EFS retention) → run
   acceptance/benchmark jobs.
3. Teardown: `pcluster delete-cluster` — safe because `/sw` (EFS) and
   license server persist independently of the cluster.

## Diagram

```
                 ┌────────────────────┐
                 │  License server EC2 │  (persistent, own lifecycle)
                 │  FlexLM + ANSYS LM  │
                 └─────────▲──────────┘
                           │ (SG: all traffic from head/compute SGs)
┌──────────────────────────┼─────────────────────────────────┐
│  ParallelCluster (SLURM)  │                                 │
│  ┌───────────────┐        │        ┌──────────────────────┐ │
│  │   Head node    │◄──────┘        │  Compute queue(s)     │ │
│  │  /sw (EFS)     │◄───────────────┤  0..N nodes, spot/OD  │ │
│  │  SLURM ctrl    │                │  /workspace (FSx)     │ │
│  └───────┬────────┘                └──────────────────────┘ │
│          │                                                   │
│   SLURM accounting DB (RDS, optional, separate CFN stack)    │
└───────────────────────────────────────────────────────────────┘
```
