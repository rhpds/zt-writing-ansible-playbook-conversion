#!/bin/bash
set -euo pipefail

tee /home/rhel/ansible-files/inventory > /dev/null <<'EOF'
[web]
node1
node2
EOF

echo "Created /home/rhel/ansible-files/inventory for rhel."
