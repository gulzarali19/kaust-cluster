# SysAdmin role split & roadmap

## Operations (recurring)

- Creation and deletion of the cluster.
- User management.
- Populating `/sw` from S3.
- Running benchmark/performance/policy tests to accept a newly
  created cluster (test suite itself is not yet defined — see
  `GAPS_AND_RECOMMENDATIONS.md`).

## Development (planned, not yet built)

- Migrate the manual cluster-creation steps to an automated pipeline
  using the AWS Boto3 API (this repo's `docs/02` + `scripts/setup` are
  the manual version to eventually wrap).
- Test MATLAB in batch mode on GPU nodes.
- SLURM commands for enforcing compute quota on queues.
- Apply Lustre quotas on a user and project basis.
- Attach `/home` to NFS and apply per-user quotas.
- Attach an ENI to the license server and enable reboot without
  losing its private IP (ties into the "persistent IP" goal in
  `04-license-server-flexlm.md`).
- Prototype DCV cluster nodes for interactive sessions and remote
  visualization.
- Annotate AWS billing/cost data with SLURM accounting information
  (once `08-slurm-accounting.md` is live, this becomes tractable —
  join billing tags to SLURM account names).
- Automate backup of FSx Lustre to S3.
- Enable Prometheus/Grafana for cluster usage monitoring.

## Suggested ownership split

Not specified in the source doc — worth deciding explicitly (e.g. who
owns "Operations" day-to-day vs. who drives "Development" items) so
the roadmap above has assigned owners rather than just a list.
