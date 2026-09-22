#!/bin/sh
# Module 09: Playbook Templates - Validation
# Validates that motd.j2 template file exists

USER="rhel"

# Check if motd.j2 template file exists
if [ ! -f /home/${USER}/ansible-files/templates/motd.j2 ]; then
    echo "FAIL: motd.j2 template file does not exist"
    exit 1
fi

echo "Module 09 validation passed: motd.j2 template file exists"
