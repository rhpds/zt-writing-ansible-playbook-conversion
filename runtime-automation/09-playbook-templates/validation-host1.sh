#!/bin/bash
set -euo pipefail

. /tmp/runtime-scripts/runtime-helper.sh

test -f "$LAB_WORKSPACE/templates/motd.j2"
run_ssh node1 grep -qx 'Welcome to node1.' /etc/motd
run_ssh node2 grep -qx 'Welcome to node2.' /etc/motd

echo "Module 09 validation passed."
