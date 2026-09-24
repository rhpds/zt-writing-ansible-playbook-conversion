#!/bin/bash
set -euo pipefail

. /tmp/runtime-scripts/runtime-helper.sh

test -f "$LAB_WORKSPACE/system_setup.yml"
grep -qx '  hosts: node1' "$LAB_WORKSPACE/system_setup.yml"
grep -qx '        name: myuser' "$LAB_WORKSPACE/system_setup.yml"

echo "Module 02 validation passed."
