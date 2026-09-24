#!/bin/bash
set -euo pipefail

. /tmp/runtime-scripts/runtime-helper.sh

run_ssh node1 id alice
run_ssh node1 id bob
run_ssh node1 id carol

echo "Module 08 validation passed."
