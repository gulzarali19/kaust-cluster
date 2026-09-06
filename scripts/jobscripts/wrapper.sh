#!/bin/bash
# Emits "hostname:slots" for the Fluent hostfile. Run once per node
# via srun from the job script. See docs/05-ansys-fluent.md.

echo "$(/bin/hostname):${SLURM_NTASKS_PER_NODE}"
