#!/bin/sh
# Module 03: verify that myuser exists on node1.
set -eu

. /tmp/runtime-scripts/runtime-helper.sh

VALIDATION_PLAYBOOK="$(mktemp /tmp/module-03-validation.XXXXXX.yml)"
trap 'rm -f "${VALIDATION_PLAYBOOK}"' EXIT HUP INT TERM

cat > "${VALIDATION_PLAYBOOK}" <<'EOF'
---
- name: Validate module 03
  hosts: node1
  become: true
  gather_facts: false
  tasks:
    - name: Check that myuser exists
      ansible.builtin.command: id myuser
      changed_when: false
EOF

run_navigator "${VALIDATION_PLAYBOOK}"
echo "Module 03 validation passed: myuser exists on node1."
