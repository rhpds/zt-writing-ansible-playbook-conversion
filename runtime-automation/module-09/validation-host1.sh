#!/bin/sh
# Module 09: verify that the learner template exists.
set -eu

. /tmp/runtime-scripts/runtime-helper.sh

require_file "${LAB_WORKSPACE}/templates/motd.j2"
echo "Module 09 validation passed: templates/motd.j2 exists."
