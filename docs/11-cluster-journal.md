# Cluster journal

A running log of head-node / license-server public IPs each time a
cluster or instance is (re)created — useful since `pcluster` assigns
a new public IP on every `create-cluster`.

Converted from the original `Cluster-journal.xlsx` (single sheet,
`Date` / `IP address` columns):

| Date       | IP address     | Notes |
|------------|----------------|-------|
| 2025-09-04 | 54.234.191.117 | (from source spreadsheet — no context given for which node/purpose) |

> Only one entry existed in the source file. Recommend logging every
> time a cluster is created/recreated — see the template below and
> consider whether this should instead be a private DNS name (as
> recommended for the license server in `04-license-server-flexlm.md`)
> so this journal becomes unnecessary for anything but audit history.

## Template for new entries

```
| YYYY-MM-DD | <public or private IP> | <cluster name> — <who/why> |
```
