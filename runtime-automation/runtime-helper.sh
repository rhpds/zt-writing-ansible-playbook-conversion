#!/bin/sh
# Shared helpers for runtime-automation scripts. This file is copied to the
# control host by runtime-automation/main.yml before a stage script runs.

LAB_USER="${LAB_USER:-rhel}"
LAB_HOME="/home/${LAB_USER}"
LAB_WORKSPACE="${LAB_HOME}/ansible-files"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

run_ssh() {
  runuser -u "${LAB_USER}" -- ssh -o StrictHostKeyChecking=no "$@"
}
