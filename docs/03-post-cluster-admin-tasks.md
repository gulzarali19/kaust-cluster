# Post-cluster-creation admin tasks

These are currently manual steps run once after a cluster comes up.
(Candidate for automation — see `GAPS_AND_RECOMMENDATIONS.md`.)

## 1. Enable license server access from the head node

Add two inbound rules to the **license server's** security group:

- All traffic from the head node's security group
- All traffic from the compute nodes' security group

Test:

```bash
module load ansys
lmutil lmstat -a
```

> Consider narrowing "all traffic" to the specific FlexLM ports once
> confirmed working — see `SECURITY.md`.

## 2. Set custom environment variables for every user (login + compute nodes)

Create `/etc/profile.d/custom_vars.sh`:

```bash
#!/bin/bash
export WORKSPACE=/workspace/$USER
export MODULEPATH=$MODULEPATH:/sw/modulefiles
```

Script provided at
[`../scripts/setup/custom_vars.sh`](../scripts/setup/custom_vars.sh) —
copy it to `/etc/profile.d/` on the head node (and anywhere else it
needs to apply).

## 3. Make an LDAP user a sudoer

```bash
# /etc/nsswitch.conf — add sudoers lookup, ldap checked before files
echo "sudoers:        ldap files" | sudo tee -a /etc/nsswitch.conf

# on the login node
sudo usermod -aG sudo user000
```

## 4. Hydrate `/sw` from S3 (if not relying on EFS retention alone)

```bash
aws s3 cp s3://rts-sw-backup/of_sw.tar .
tar xvf of_sw.tar -C /sw --strip-components=1
```

## 5. Create per-user scratch directories

```bash
for i in $(seq -f "%03g" 21); do
  user="training${i}"
  group=normal
  sudo mkdir -p /scratch/${user}
  sudo chown ${user}:${group} -R /scratch/${user}
  sudo chmod 0755 -R /scratch/${user}
done
```

Script provided at
[`../scripts/setup/create-scratch-dirs.sh`](../scripts/setup/create-scratch-dirs.sh),
parameterized instead of hardcoded to `training001`–`training021`.
