#!/bin/sh
# Module 01: verify that the learner created an inventory file.
set -eu

LAB_USER="${LAB_USER:-rhel}"
LAB_WORKSPACE="/home/${LAB_USER}/ansible-files"

[ -f "${LAB_WORKSPACE}/inventory" ] || {
  echo "ERROR: ${LAB_WORKSPACE}/inventory does not exist." >&2
  exit 1
}

echo "Module 01 validation passed: inventory exists."
