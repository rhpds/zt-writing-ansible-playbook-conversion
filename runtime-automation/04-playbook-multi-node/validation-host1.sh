#!/bin/bash
set -euo pipefail

. /tmp/runtime-scripts/runtime-helper.sh

run_ssh node1 id myuser
run_ssh node2 id myuser

echo "Module 04 validation passed."
