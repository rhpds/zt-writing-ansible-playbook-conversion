#!/bin/bash
set -euo pipefail

tee /home/rhel/ansible-files/system_setup.yml > /dev/null <<'EOF'
---
- name: Basic System Setup
  hosts: web
  become: true
  tasks:
    - name: Install security updates for the kernel
      ansible.builtin.dnf:
        name: kernel
        state: latest
        security: true

    - name: Create a new user
      ansible.builtin.user:
        name: myuser
        state: present
        create_home: true
EOF

cd /home/rhel/ansible-files
ansible-navigator run system_setup.yml

echo "Updated system_setup.yml for the web group."
