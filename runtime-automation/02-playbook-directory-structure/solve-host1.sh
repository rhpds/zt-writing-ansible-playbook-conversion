#!/bin/bash
set -euo pipefail

tee /home/rhel/ansible-files/system_setup.yml << EOF
---
- name: Basic System Setup
  hosts: node1
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

echo "Created system_setup.yml."
