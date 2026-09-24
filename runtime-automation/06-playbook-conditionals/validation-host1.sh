#!/bin/bash
set -euo pipefail

. /tmp/runtime-scripts/runtime-helper.sh

run_ssh node1 id padawan
run_ssh node2 id padawan
run_ssh node3 id padawan
run_ssh node1 rpm -q httpd
run_ssh node2 rpm -q httpd

if run_ssh node3 rpm -q httpd; then
  fail "httpd must not be installed on node3."
fi

echo "Module 06 validation passed."
