#!/bin/bash
set -euo pipefail

curl -fsS http://node1 | grep -q 'HTTP Server'
curl -fsS http://node2 | grep -q 'HTTP Server'

echo "Module 07 validation passed."
