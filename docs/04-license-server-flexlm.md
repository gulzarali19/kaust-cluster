# License server (FlexLM + ANSYS)

Goal: a FlexLM server with a **persistent** private IP, independent
of the ParallelCluster lifecycle, serving licenses to the head node
and compute nodes.

> The doc this was built from is titled "persistent IP address" but
> the configs and modulefiles reference the license server by raw IP
> (e.g. `ip-10-0-26-35.ec2.internal`). If the instance is ever
> recreated its IP can change even if you intended it to be static.
> Consider a private Route 53 hosted zone (e.g. `license.internal`)
> pointed at the instance, or an Elastic Network Interface with a
> fixed private IP attached to a new instance on replacement — see
> `GAPS_AND_RECOMMENDATIONS.md`.

## 1. Create the instance

- Create the ParallelCluster's VPC and subnets first (or reuse them).
- Use the CloudFormation template `flexlm_working.yaml` (kept
  alongside this repo's infra, or wherever your team stores it) to
  launch the license server stack, in the **same region** as the
  cluster.
- Select the **private** subnet (the one used for compute nodes).

## 2. Security group

On the license server's security group, add inbound rules:

| Rule | Type | Source |
|------|------|--------|
| 1 | All traffic | SLURM cluster head node SG |
| 2 | All traffic | SLURM cluster compute node SG |

## 3. Connect

```bash
scp -i <path-to-pem> license-server.pem ec2-user@<head-node>:
ssh -i <path-to-pem> ec2-user@<license-server-private-ip>
```

## 4. Enable outbound internet (private subnet) to install dependencies

See: [How to access internet on AWS EC2 under a private subnet](https://krishnendubhowmick.medium.com/how-to-access-internet-on-aws-ec2-under-a-private-subnet-165b2ef260c6)
(needs a NAT gateway/instance on the route table).

```bash
sudo yum install -y expat fontconfig freetype glib2 glibc gmp gnutls \
  libICE libSM libX11 libXau libXext libXrender libffi libgcc libidn2 \
  libpng libstdc++ libtasn1 libunistring libuuid libxcb nettle p11-kit \
  pcre zlib
```

## 5. Get a license file from the vendor

1. Download and untar the vendor's host-ID query tool (`LINX64.tar`,
   from your internal S3 bucket).
2. Run `GetLinx64Hostid` to produce `license.info`.
3. **Amazon Linux quirk**: the tool looks for
   `ld-lsb-x86_64.so.3`, which doesn't exist under that name on
   Amazon Linux (it's `ld-linux-x86-64.so.2`). Symlink it:

   ```bash
   sudo ln -s /lib64/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
   ```

4. Send `license.info` to the vendor; they return a license text file.

## 6. Install the ANSYS license manager

Download `ANSYSLICMAN_<version>_LINX64.tgz` from the
[ANSYS support portal](https://support.ansys.com/Home/HomePage),
untar it on the license server.

```bash
cp license.txt lic_install/ansyslmd.lic

./INSTALL -silent -LM \
  -install_dir /home/ec2-user/lic_install/ \
  -licfilepath /home/ec2-user/lic_install/ansyslmd.lic

cp ansyslmd.lic lic_install/shared_files/licensing/license_files/
```

Start the license service:

```bash
sudo ./lic_install/shared_files/licensing/start_ansyslmd
```

> **Note (observed 2025‑03‑26, ANSYS R2/2023)**: `start_ansyslmd` was
> not present after install, but the install step itself already
> started the server processes, and the test below still succeeded —
> this step may be redundant on newer ANSYS versions. Verify before
> assuming it's needed.

## 7. Test

```bash
./lic_install/shared_files/licensing/linx64/lmutil lmstat -a \
  -c 1055@ip-10-0-26-35.ec2.internal
```
