#!/bin/bash
set -euo pipefail

WORKSPACE=/home/rhel/ansible-files

cat > "$WORKSPACE/inventory" <<'EOF'
[web]
node1
node2
EOF
chown rhel:rhel "$WORKSPACE/inventory"

echo "Created $WORKSPACE/inventory for rhel."
