# Creating the cluster

## 1. Generate a config interactively

```bash
pcluster configure --config config_cluster.yaml
```

This launches a wizard. Answers you'll be asked for (values used
previously are noted where relevant):

| # | Question | Notes |
|---|----------|-------|
| 1 | AWS Region | e.g. `us-east-1` |
| 2 | EC2 Key Pair | the key created in prerequisites |
| 3 | Scheduler | `slurm` |
| 4 | Operating System | `ubuntu2204` / `ubuntu2404` / `alinux2023` / `rhel8` / `rhel9` / `rocky8` / `rocky9` |
| 5 | Head node instance type | see instance naming note below |
| 6 | Number of queues | number of SLURM partitions |
| 7 | Number of compute resources per queue | |
| 8 | Compute instance type | e.g. `c7a.large` |
| 9 | Max instance count | per compute resource |
| 10 | Automate VPC creation | yes = new VPC, no = pick existing |
| 11 | Automate subnet creation | no if you already have public (head node) / private (compute) subnets |

**EC2 instance type naming**: `[family][generation][attributes].[size]`
— e.g. `c7i-flex.large` = Compute-optimized, 7th gen, Intel with Flex
option, `large` (2 vCPU / 4 GB RAM).

The wizard does **not** configure shared storage — add that manually
(see step 2).

## 2. Add shared storage, head node, and queue tuning

The wizard's output needs these blocks added/edited. A ready-to-adapt
version is at
[`../configs/cluster-config-hpc-features.yaml`](../configs/cluster-config-hpc-features.yaml).
Key choices baked into it:

- `SharedStorage`:
  - `FsxLustre` at `/workspace` — scratch, deleted with the cluster.
  - `Efs` at `/sw` — software tree, **retained** on cluster deletion.
- Head node: larger root volume for software builds, S3 read-only
  access for a bootstrap script bucket, a custom `OnNodeConfigured`
  script.
- Compute queue: `JobExclusiveAllocation: true` (one job gets the
  whole node), spot capacity, hyperthreading disabled, EFA disabled
  (enable if using an interconnect-sensitive MPI workload on
  EFA-capable instance types), placement group disabled.

A minimal, no-frills example (single EBS-backed shared volume) is at
[`../configs/cluster-config-appendix-a-minimal.yaml`](../configs/cluster-config-appendix-a-minimal.yaml).

## 3. Create the cluster

```bash
pcluster create-cluster -n cfd01 -c config_cluster.yaml
```

Check status:

```bash
pcluster list-clusters
pcluster describe-cluster -n cfd01
```

## 4. Connect

```bash
pcluster ssh -n cfd01 -i ~/.ssh/your-key.pem
```

## 5. Delete the cluster

```bash
pcluster delete-cluster -n cfd01
```

Safe to do at any time if `/sw` is on EFS with `DeletionPolicy: Retain`
— software and license configuration survive; only compute + head
node + Lustre scratch are torn down.

## Regression / acceptance testing

Not yet defined in the source docs — see
[`../GAPS_AND_RECOMMENDATIONS.md`](../GAPS_AND_RECOMMENDATIONS.md).
The `SysAdmin-Role-Assignment` notes list "run benchmark for
performance and policy tests to accept the cluster" as an operational
task; there's no benchmark suite documented yet.
