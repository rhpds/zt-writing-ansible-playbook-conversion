#!/bin/sh
# Module 03: run the first playbook as the learner.
set -eu

. /tmp/runtime-scripts/runtime-helper.sh

run_navigator "${LAB_WORKSPACE}/system_setup.yml"
echo "Module 03 solve complete."
