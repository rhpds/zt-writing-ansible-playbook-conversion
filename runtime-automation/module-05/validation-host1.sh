#!/bin/sh
# Module 05: Playbook Variables - Validation
# Validates that the padawan user exists on web nodes

# Check if padawan user exists on node1
if ssh -o StrictHostKeyChecking=no rhel@node1 "id padawan" > /dev/null 2>&1; then
    echo "SUCCESS: padawan user exists on node1"
else
    echo "FAIL: padawan user does not exist on node1"
    exit 1
fi

# Check if padawan user exists on node2
if ssh -o StrictHostKeyChecking=no rhel@node2 "id padawan" > /dev/null 2>&1; then
    echo "SUCCESS: padawan user exists on node2"
else
    echo "FAIL: padawan user does not exist on node2"
    exit 1
fi

echo "Module 05 validation passed: padawan user exists on all web nodes"
