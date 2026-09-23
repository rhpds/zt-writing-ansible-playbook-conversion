#!/bin/sh
# Module 01: verify the workspace prepared during lab provisioning.
set -eu

LAB_USER="${LAB_USER:-rhel}"
LAB_WORKSPACE="/home/${LAB_USER}/ansible-files"
NAVIGATOR_CONFIG="${LAB_WORKSPACE}/ansible-navigator.yml"

[ -d "${LAB_WORKSPACE}" ] || {
  echo "ERROR: ${LAB_WORKSPACE} was not created during provisioning." >&2
  exit 1
}

[ -f "${NAVIGATOR_CONFIG}" ] || {
  echo "ERROR: ${NAVIGATOR_CONFIG} was not created during provisioning." >&2
  exit 1
}

echo "Module 01 setup check passed: ${LAB_WORKSPACE} is ready."
