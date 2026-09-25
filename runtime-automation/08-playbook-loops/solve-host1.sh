#!/bin/bash
set -euo pipefail

tee /home/rhel/ansible-files/loop_users.yml > /dev/null <<'EOF'
---
- name: Create multiple users with a loop
  hosts: node1
  become: true
  tasks:
    - name: Create a new user
      ansible.builtin.user:
        name: "{{ item }}"
        state: present
        create_home: true
      loop:
        - alice
        - bob
        - carol
EOF

cd /home/rhel/ansible-files
ansible-navigator run loop_users.yml

echo "Created and ran loop_users.yml."
