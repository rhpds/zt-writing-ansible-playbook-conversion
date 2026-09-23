#!/bin/sh
# Module 04: verify that myuser exists on each web node.
set -eu

. /tmp/runtime-scripts/runtime-helper.sh

VALIDATION_PLAYBOOK="$(mktemp /tmp/module-04-validation.XXXXXX.yml)"
trap 'rm -f "${VALIDATION_PLAYBOOK}"' EXIT HUP INT TERM
cat > "${VALIDATION_PLAYBOOK}" <<'EOF'
---
- name: Validate module 04
  hosts: web
  become: true
  gather_facts: false
  tasks:
    - name: Check that myuser exists
      ansible.builtin.command: id myuser
      changed_when: false
EOF
run_navigator "${VALIDATION_PLAYBOOK}"
echo "Module 04 validation passed: myuser exists on the web nodes."
