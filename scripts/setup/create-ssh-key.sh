#!/bin/bash
# Create an ed25519 EC2 key pair and install it locally with correct
# permissions. See docs/01-prerequisites.md.
set -euo pipefail

KEY_NAME="${1:?Usage: create-ssh-key.sh <key-name>}"
DEST="${HOME}/.ssh/${KEY_NAME}.pem"

aws ec2 create-key-pair --key-name "${KEY_NAME}" \
  --query 'KeyMaterial' --output text \
  --key-type ed25519 > "${DEST}"

chmod 400 "${DEST}"
echo "Key saved to ${DEST}"
