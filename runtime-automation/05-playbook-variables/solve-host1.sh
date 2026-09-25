#!/bin/bash
set -euo pipefail

tee /home/rhel/ansible-files/system_setup.yml > /dev/null <<'EOF'
---
- name: Basic System Setup
  hosts: web
  become: true
  vars:
    user_name: padawan
  tasks:
    - name: Install security updates for the kernel
      ansible.builtin.dnf:
        name: kernel
        state: latest
        security: true

    - name: Create a new user
      ansible.builtin.user:
        name: "{{ user_name }}"
        state: present
        create_home: true
EOF

cd /home/rhel/ansible-files
ansible-navigator run system_setup.yml

echo "Added the user_name variable."
