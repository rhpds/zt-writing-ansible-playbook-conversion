#!/bin/sh
# Module 05: verify that padawan exists on each web node.
set -eu

. /tmp/runtime-scripts/runtime-helper.sh

VALIDATION_PLAYBOOK="$(mktemp /tmp/module-05-validation.XXXXXX.yml)"
trap 'rm -f "${VALIDATION_PLAYBOOK}"' EXIT HUP INT TERM
cat > "${VALIDATION_PLAYBOOK}" <<'EOF'
---
- name: Validate module 05
  hosts: web
  become: true
  gather_facts: false
  tasks:
    - name: Check that padawan exists
      ansible.builtin.command: id padawan
      changed_when: false
EOF
run_navigator "${VALIDATION_PLAYBOOK}"
echo "Module 05 validation passed: padawan exists on the web nodes."
