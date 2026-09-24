#!/bin/bash
set -euo pipefail

WORKSPACE=/home/rhel/ansible-files

runuser -u rhel -- tee "$WORKSPACE/inventory" > /dev/null <<'EOF'
[web]
node1
node2
EOF

echo "Created $WORKSPACE/inventory for rhel."
