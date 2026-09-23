#!/bin/sh
# Module 08: verify the loop playbook and its users.
set -eu

. /tmp/runtime-scripts/runtime-helper.sh

require_file "${LAB_WORKSPACE}/loop_users.yml"
VALIDATION_PLAYBOOK="$(mktemp /tmp/module-08-validation.XXXXXX.yml)"
trap 'rm -f "${VALIDATION_PLAYBOOK}"' EXIT HUP INT TERM
cat > "${VALIDATION_PLAYBOOK}" <<'EOF'
---
- name: Validate module 08
  hosts: node1
  become: true
  gather_facts: false
  tasks:
    - name: Check that loop users exist
      ansible.builtin.command: "id {{ item }}"
      changed_when: false
      loop:
        - alice
        - bob
        - carol
EOF
run_navigator "${VALIDATION_PLAYBOOK}"
echo "Module 08 validation passed: loop_users.yml and all users exist."
