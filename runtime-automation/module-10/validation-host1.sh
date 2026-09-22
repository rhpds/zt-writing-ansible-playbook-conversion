#!/bin/sh
# Module 10: Roles - Validation
# Validates that apache role exists and web pages are accessible

USER="rhel"

# Check if apache role directory exists
if [ ! -d /home/${USER}/ansible-files/roles/apache ]; then
    echo "FAIL: Apache role does not exist"
    exit 1
fi

# Check if web page is accessible on node1
if ! curl -s http://node1 | grep -q "Welcome to node"; then
    echo "FAIL: Web page is not accessible on node1 or does not contain expected content"
    exit 1
fi

# Check if web page is accessible on node2
if ! curl -s http://node2 | grep -q "Welcome to node"; then
    echo "FAIL: Web page is not accessible on node2 or does not contain expected content"
    exit 1
fi

echo "Module 10 validation passed: Apache role exists and web pages are accessible"
