#!/bin/bash
set -euo pipefail

test -f /home/rhel/ansible-files/roles/apache/tasks/main.yml
test -f /home/rhel/ansible-files/roles/apache/handlers/main.yml
test -f /home/rhel/ansible-files/roles/apache/templates/index.html.j2
curl -fsS http://node1 | grep -q 'Hello from node1'
curl -fsS http://node2 | grep -q 'Hello from node2'

echo "Module 10 validation passed."
