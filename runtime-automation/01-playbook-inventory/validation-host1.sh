#!/bin/sh
# Module 01: verify that the learner created an inventory file.
set -eu

. /tmp/runtime-scripts/runtime-helper.sh

require_file "${LAB_WORKSPACE}/inventory"
echo "Module 01 validation passed: inventory exists."
