#!/bin/bash
# Create per-user scratch directories with correct ownership/perms.
# See docs/03-post-cluster-admin-tasks.md.
#
# Usage: create-scratch-dirs.sh <prefix> <count> <group>
#   e.g. create-scratch-dirs.sh training 21 normal
#   creates /scratch/training001 .. /scratch/training021, group "normal"
set -euo pipefail

PREFIX="${1:?Usage: create-scratch-dirs.sh <user-prefix> <count> <group>}"
COUNT="${2:?count required}"
GROUP="${3:?group required}"

for i in $(seq -f "%03g" "${COUNT}"); do
  user="${PREFIX}${i}"
  sudo mkdir -p "/scratch/${user}"
  sudo chown -R "${user}:${GROUP}" "/scratch/${user}"
  sudo chmod -R 0755 "/scratch/${user}"
done

echo "Created scratch dirs for ${COUNT} users with prefix '${PREFIX}'."
