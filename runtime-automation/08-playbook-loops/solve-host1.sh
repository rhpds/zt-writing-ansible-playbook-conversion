#!/bin/bash
set -euo pipefail

. /tmp/runtime-scripts/runtime-helper.sh

write_workspace_file loop_users.yml <<'EOF'
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

run_navigator loop_users.yml

echo "Created and ran loop_users.yml."
