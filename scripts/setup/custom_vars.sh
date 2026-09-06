#!/bin/bash
# Install to /etc/profile.d/custom_vars.sh on the head node (and any
# node where these should apply). See docs/03-post-cluster-admin-tasks.md.

export WORKSPACE=/workspace/$USER
export MODULEPATH=$MODULEPATH:/sw/modulefiles
