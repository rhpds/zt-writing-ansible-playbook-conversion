#!/bin/sh
# Module 04: Playbook Multi Node - Validation
# Validates that myuser exists on web nodes

# Check if myuser exists on node1
if ssh -o StrictHostKeyChecking=no rhel@node1 "id myuser" > /dev/null 2>&1; then
    echo "SUCCESS: myuser exists on node1"
else
    echo "FAIL: myuser does not exist on node1"
    exit 1
fi

# Check if myuser exists on node2
if ssh -o StrictHostKeyChecking=no rhel@node2 "id myuser" > /dev/null 2>&1; then
    echo "SUCCESS: myuser exists on node2"
else
    echo "FAIL: myuser does not exist on node2"
    exit 1
fi

echo "Module 04 validation passed: myuser exists on all web nodes"
