#!/bin/sh
# Module 02: verify that the first playbook exists.
set -eu

. /tmp/runtime-scripts/runtime-helper.sh

require_file "${LAB_WORKSPACE}/system_setup.yml"
echo "Module 02 validation passed: system_setup.yml exists."
