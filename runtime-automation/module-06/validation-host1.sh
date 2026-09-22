#!/bin/sh
# Module 06: Playbook Conditionals - Validation
# Validates that httpd is installed on web nodes

# Check if httpd is installed on node1
if ssh -o StrictHostKeyChecking=no rhel@node1 "rpm -q httpd" > /dev/null 2>&1; then
    echo "SUCCESS: httpd is installed on node1"
else
    echo "FAIL: httpd is not installed on node1"
    exit 1
fi

# Check if httpd is installed on node2
if ssh -o StrictHostKeyChecking=no rhel@node2 "rpm -q httpd" > /dev/null 2>&1; then
    echo "SUCCESS: httpd is installed on node2"
else
    echo "FAIL: httpd is not installed on node2"
    exit 1
fi

echo "Module 06 validation passed: httpd is installed on all web nodes"
