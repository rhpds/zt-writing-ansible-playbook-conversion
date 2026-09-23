#!/bin/sh
# Module 06: verify that httpd is installed on the web nodes.
set -eu

. /tmp/runtime-scripts/runtime-helper.sh

VALIDATION_PLAYBOOK="$(mktemp /tmp/module-06-validation.XXXXXX.yml)"
trap 'rm -f "${VALIDATION_PLAYBOOK}"' EXIT HUP INT TERM
cat > "${VALIDATION_PLAYBOOK}" <<'EOF'
---
- name: Validate module 06
  hosts: web
  become: true
  gather_facts: false
  tasks:
    - name: Gather installed RPM package facts
      ansible.builtin.package_facts:
        manager: rpm
    - name: Require the httpd package
      ansible.builtin.assert:
        that: "'httpd' in ansible_facts.packages"
        fail_msg: httpd is not installed
EOF
run_navigator "${VALIDATION_PLAYBOOK}"
echo "Module 06 validation passed: httpd is installed on the web nodes."
