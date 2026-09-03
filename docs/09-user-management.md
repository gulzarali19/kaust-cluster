# User & account management

## Two modes in use today

1. **Active Directory / LDAP** (preferred) — see
   `03-post-cluster-admin-tasks.md` for making an LDAP user a sudoer
   via `nsswitch.conf` + `usermod`.
2. **Manual local users** (when AD isn't set up) — see
   `07-running-jobs.md` for `useradd`/`groupadd`/`passwd`/`deluser`.

## Account/credential inventory — moved out of this repo

The original `Account information.docx` held a flat list of shared
admin and per-user passwords (AWS root, console admins, AD admin,
SLURM DB admin, sudoer user, and individual `user000`–`user002`
accounts). That pattern doesn't scale past a handful of people and
is a standing security risk (see `../SECURITY.md`).

**Recommended replacement**, once AD/LDAP is fully in place:

- One AD/LDAP account per human, no shared logins.
- AWS access via IAM roles / SSO, not shared console passwords.
- Service credentials (SLURM DB, license server) in AWS Secrets
  Manager, referenced by ARN from configs — already the pattern used
  in `08-slurm-accounting.md`.
- If you still need a lightweight local roster for a small/temporary
  cluster, use `configs/secrets.env.example` as the template and keep
  the filled-in `.env` out of git (already gitignored).

## Quota / project structure (planned, not yet implemented)

From the roadmap (`10-roles-and-roadmap.md`):

- Lustre quotas on a user and project basis.
- `/home` on NFS with per-user quotas.
- SLURM commands to enforce compute quota per queue.

These should be designed together — a "project" in Lustre quota terms
should probably map 1:1 to a SLURM account (see `08-slurm-accounting.md`).
