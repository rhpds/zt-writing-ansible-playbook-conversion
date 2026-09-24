#!/bin/bash
set -euo pipefail

. /tmp/runtime-scripts/runtime-helper.sh

write_workspace_file system_setup.yml <<'EOF'
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

run_navigator system_setup.yml

echo "Added the user_name variable."
