#!/bin/sh
# Module 10: verify the Apache role and its rendered page.
set -eu

. /tmp/runtime-scripts/runtime-helper.sh

require_directory "${LAB_WORKSPACE}/roles/apache"
VALIDATION_PLAYBOOK="$(mktemp /tmp/module-10-validation.XXXXXX.yml)"
trap 'rm -f "${VALIDATION_PLAYBOOK}"' EXIT HUP INT TERM
cat > "${VALIDATION_PLAYBOOK}" <<'EOF'
---
- name: Validate module 10
  hosts: web
  become: true
  gather_facts: false
  tasks:
    - name: Retrieve the deployed Apache page
      ansible.builtin.uri:
        url: "http://{{ inventory_hostname }}"
        return_content: true
        status_code: 200
      register: page
    - name: Require the expected rendered page content
      ansible.builtin.assert:
        that: "'Welcome to node' in page.content"
        fail_msg: "{{ inventory_hostname }} does not serve the expected Apache page"
EOF
run_navigator "${VALIDATION_PLAYBOOK}"
echo "Module 10 validation passed: the Apache role and web pages are available."
