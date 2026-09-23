#!/bin/sh
# Module 07: verify firewalld and the default HTTP page on web nodes.
set -eu

. /tmp/runtime-scripts/runtime-helper.sh

VALIDATION_PLAYBOOK="$(mktemp /tmp/module-07-validation.XXXXXX.yml)"
trap 'rm -f "${VALIDATION_PLAYBOOK}"' EXIT HUP INT TERM
cat > "${VALIDATION_PLAYBOOK}" <<'EOF'
---
- name: Validate module 07
  hosts: web
  become: true
  gather_facts: false
  tasks:
    - name: Gather installed RPM package facts
      ansible.builtin.package_facts:
        manager: rpm
    - name: Require the firewalld package
      ansible.builtin.assert:
        that: "'firewalld' in ansible_facts.packages"
        fail_msg: firewalld is not installed
    - name: Retrieve the default HTTP page
      ansible.builtin.uri:
        url: "http://{{ inventory_hostname }}"
        return_content: true
        status_code: [200, 403]
      register: page
    - name: Require the expected HTTP page content
      ansible.builtin.assert:
        that: "'Test Page for the HTTP Server on Red Hat Enterprise Linux' in page.content"
        fail_msg: "{{ inventory_hostname }} does not serve the expected HTTP page"
EOF
run_navigator "${VALIDATION_PLAYBOOK}"
echo "Module 07 validation passed: firewalld and HTTP are available."
