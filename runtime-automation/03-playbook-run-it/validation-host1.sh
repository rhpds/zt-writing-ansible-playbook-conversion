#!/bin/bash
set -euo pipefail

. /tmp/runtime-scripts/runtime-helper.sh

run_ssh node1 id myuser

echo "Module 03 validation passed."
