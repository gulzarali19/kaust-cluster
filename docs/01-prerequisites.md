# Prerequisites

## AWS account setup

- An AWS user/role with Admin (or sufficiently scoped) access.
- An AWS Access Key + Secret Key for that user:
  1. AWS Console → top-right profile menu → **Security credentials**.
  2. Scroll to **Access keys** → create one.
  3. Download the key as CSV — it is **not retrievable again** after
     you close the page.

> Prefer IAM roles / SSO over long-lived access keys where possible.
> If you must use access keys, store them in your AWS CLI credential
> file or a secrets manager — never in a doc or script.

## Local / bastion tooling

```bash
# 1. Isolated conda env for the AWS CLI + ParallelCluster tooling
conda create -n awscli python=3.9
conda activate awscli

# 2. AWS CLI v2
pip install awscliv2
awsv2 --install
# --- OR, if you don't already have awscli v2 (check: aws --version) ---
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
bash ./aws/install -i "${CONDA_PREFIX}" -b "${CONDA_PREFIX}/bin"

# 3. AWS ParallelCluster CLI + Node.js (required by pcluster for
#    the CloudFormation/CDK based cluster templates)
pip install aws-parallelcluster
conda install -c conda-forge nodejs -y

# 4. Verify
pcluster version   # expect 3.8.0 or above
```

Helper script: [`../scripts/setup/install-awscli-pcluster.sh`](../scripts/setup/install-awscli-pcluster.sh)

## Configure AWS credentials for this session

```bash
aws configure
# prompts for Access Key ID and Secret Access Key
```

## SSH key for EC2

Ubuntu 22.04/24.04 images support `ed25519` keys:

```bash
aws ec2 create-key-pair --key-name your-key --query KeyMaterial \
  --output text --key-type ed25519 > your-key.pem
mv your-key.pem ~/.ssh/your-key.pem
chmod 400 ~/.ssh/your-key.pem
```

Helper script: [`../scripts/setup/create-ssh-key.sh`](../scripts/setup/create-ssh-key.sh)
