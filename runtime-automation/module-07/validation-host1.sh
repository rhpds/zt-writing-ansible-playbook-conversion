#!/bin/sh
# Module 07: Handlers - Validation
# Validates that firewalld is installed and web is accessible

# Check if firewalld is installed on node1
if ! ssh -o StrictHostKeyChecking=no rhel@node1 "rpm -q firewalld" > /dev/null 2>&1; then
    echo "FAIL: firewalld is not installed on node1"
    exit 1
fi

# Check if firewalld is installed on node2
if ! ssh -o StrictHostKeyChecking=no rhel@node2 "rpm -q firewalld" > /dev/null 2>&1; then
    echo "FAIL: firewalld is not installed on node2"
    exit 1
fi

# Check if HTTP is accessible on node1
if ! curl -s http://node1 | grep -q "Test Page for the HTTP Server on Red Hat Enterprise Linux"; then
    echo "FAIL: Web page is not accessible on node1"
    exit 1
fi

# Check if HTTP is accessible on node2
if ! curl -s http://node2 | grep -q "Test Page for the HTTP Server on Red Hat Enterprise Linux"; then
    echo "FAIL: Web page is not accessible on node2"
    exit 1
fi

echo "Module 07 validation passed: firewalld installed and web accessible on all web nodes"
