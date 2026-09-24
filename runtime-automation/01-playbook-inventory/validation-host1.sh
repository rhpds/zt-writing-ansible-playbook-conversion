#!/bin/bash
set -euo pipefail

INVENTORY=/home/rhel/ansible-files/inventory

test -f "$INVENTORY"
grep -qx '\[web\]' "$INVENTORY"
grep -qx 'node1' "$INVENTORY"
grep -qx 'node2' "$INVENTORY"

echo "Module 01 validation passed."
