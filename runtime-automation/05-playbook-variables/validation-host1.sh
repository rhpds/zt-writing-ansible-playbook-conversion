#!/bin/bash
set -euo pipefail

run_ssh node1 id padawan
run_ssh node2 id padawan

echo "Module 05 validation passed."
