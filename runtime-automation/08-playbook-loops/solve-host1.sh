#!/bin/bash
set -euo pipefail

WORKSPACE=/home/rhel/ansible-files

runuser -u rhel -- tee "$WORKSPACE/loop_users.yml" > /dev/null <<'EOF'
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

runuser -u rhel -- env HOME=/home/rhel XDG_RUNTIME_DIR="/run/user/$(id -u rhel)" \
  bash -c "cd \"$WORKSPACE\" && ansible-navigator run loop_users.yml --mode stdout"

echo "Created and ran loop_users.yml."
