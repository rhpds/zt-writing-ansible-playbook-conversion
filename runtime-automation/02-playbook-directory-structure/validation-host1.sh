#!/bin/bash
set -euo pipefail

PLAYBOOK=/home/rhel/ansible-files/system_setup.yml

test -f "$PLAYBOOK"
grep -qx -- '---' "$PLAYBOOK"
grep -qx -- '- name: Basic System Setup' "$PLAYBOOK"
grep -qx -- '  hosts: node1' "$PLAYBOOK"
grep -qx -- '  become: true' "$PLAYBOOK"
grep -qx -- '    - name: Install security updates for the kernel' "$PLAYBOOK"
grep -qx -- '      ansible.builtin.dnf:' "$PLAYBOOK"
grep -qx -- '        name: kernel' "$PLAYBOOK"
grep -qx -- '        state: latest' "$PLAYBOOK"
grep -qx -- '        security: true' "$PLAYBOOK"
grep -qx -- '    - name: Create a new user' "$PLAYBOOK"
grep -qx -- '      ansible.builtin.user:' "$PLAYBOOK"
grep -qx -- '        name: myuser' "$PLAYBOOK"
grep -qx -- '        state: present' "$PLAYBOOK"
grep -qx -- '        create_home: true' "$PLAYBOOK"

echo "Module 02 validation passed."
