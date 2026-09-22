#!/bin/sh
# Module 08: Playbook Loops - Validation
# Validates that loop_users.yml exists and users are created

USER="rhel"

# Check if loop_users.yml file exists
if [ ! -f /home/${USER}/ansible-files/loop_users.yml ]; then
    echo "FAIL: loop_users.yml file does not exist"
    exit 1
fi

# Check if alice user exists on node1
if ! ssh -o StrictHostKeyChecking=no rhel@node1 "id alice" > /dev/null 2>&1; then
    echo "FAIL: User alice does not exist on node1"
    exit 1
fi

# Check if bob user exists on node1
if ! ssh -o StrictHostKeyChecking=no rhel@node1 "id bob" > /dev/null 2>&1; then
    echo "FAIL: User bob does not exist on node1"
    exit 1
fi

# Check if carol user exists on node1
if ! ssh -o StrictHostKeyChecking=no rhel@node1 "id carol" > /dev/null 2>&1; then
    echo "FAIL: User carol does not exist on node1"
    exit 1
fi

echo "Module 08 validation passed: loop_users.yml exists and all users created"
