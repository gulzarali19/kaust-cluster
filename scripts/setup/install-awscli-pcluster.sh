#!/bin/bash
# One-time setup of an isolated conda env with awscli v2 + AWS
# ParallelCluster CLI. See docs/01-prerequisites.md.
set -euo pipefail

ENV_NAME="${1:-awscli}"

conda create -y -n "${ENV_NAME}" python=3.9
# shellcheck disable=SC1091
source "$(conda info --base)/etc/profile.d/conda.sh"
conda activate "${ENV_NAME}"

if ! command -v aws >/dev/null 2>&1 || [[ "$(aws --version 2>&1)" != *"aws-cli/2"* ]]; then
  echo "Installing awscli v2..."
  curl -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
  unzip -q awscliv2.zip
  bash ./aws/install -i "${CONDA_PREFIX}" -b "${CONDA_PREFIX}/bin"
  rm -rf awscliv2.zip aws/
else
  echo "awscli v2 already present: $(aws --version)"
fi

pip install aws-parallelcluster
conda install -y -c conda-forge nodejs

echo "pcluster version: $(pcluster version)"
echo "Run 'conda activate ${ENV_NAME} && aws configure' next."
