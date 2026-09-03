# SLURM accounting (RDS-backed)

## Prerequisites

- A VPC must already exist for the cluster. Run `pcluster configure`
  and let it create the VPC, but **do not create the cluster yet**.
- With the VPC in place, use the SLURM DB CloudFormation template
  (linked from the AWS console's CloudFormation home) to create the
  accounting database.
- Leave the subnet fields empty so new subnets are created inside the
  same VPC.
- For the new subnets' CIDR blocks, check the existing subnets' CIDRs
  in that VPC and pick a non-overlapping offset — e.g. if existing
  subnets use `10.0.0.0/24` and `10.0.16.0/24`, use something like
  `10.0.32.0/24` and `10.0.64.0/24`.
- Password policy for the DB admin: pattern like `##-ABCD-####`
  (numbers / letters / hyphens) — generate this with a secrets
  manager, don't hand-type it.
- From the stack's **Outputs** tab, note: `DatabaseHost`,
  `DatabaseAdminUser`, `DatabaseSecretArn`.

## Update the cluster config

Full example:
[`../configs/cluster-config-slurm-accounting-example.yaml`](../configs/cluster-config-slurm-accounting-example.yaml)

Relevant block:

```yaml
Scheduling:
  Scheduler: slurm
  SlurmSettings:
    Database:
      Uri: <DatabaseHost from stack outputs>
      UserName: <DatabaseAdminUser from stack outputs>
      PasswordSecretArn: <DatabaseSecretArn from stack outputs>
```

This is the pattern to follow for **all** secrets in cluster configs —
a Secrets Manager ARN, never a plaintext password in the YAML.

## Create a project (account) and add users

```bash
sacctmgr create account name=dev
sacctmgr create user name=user01 account=dev
sacctmgr create user name=user02 account=dev
sacctmgr create user name=user03 account=dev
```

Tie this into the "Apply Lustre quotas on user and project basis" and
"SLURM commands for enforcing compute quota on queues" items from the
roadmap (`10-roles-and-roadmap.md`) once accounting is live — SLURM
accounts map naturally onto quota/QOS policies.
