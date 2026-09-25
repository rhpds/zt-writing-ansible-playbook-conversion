#!/bin/bash
set -euo pipefail

WORKSPACE=/home/rhel/ansible-files

runuser -u rhel -- tee "$WORKSPACE/system_setup.yml" > /dev/null <<'EOF'
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

runuser -u rhel -- env HOME=/home/rhel XDG_RUNTIME_DIR="/run/user/$(id -u rhel)" \
  bash -c "cd \"$WORKSPACE\" && ansible-navigator run system_setup.yml --mode stdout"

echo "Updated system_setup.yml for the web group."
