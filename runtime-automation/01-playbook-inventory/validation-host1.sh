#!/bin/bash
set -euo pipefail

test -f /home/rhel/ansible-files/inventory
grep -qx '\[web\]' /home/rhel/ansible-files/inventory
grep -qx 'node1' /home/rhel/ansible-files/inventory
grep -qx 'node2' /home/rhel/ansible-files/inventory

echo "Module 01 validation passed."
