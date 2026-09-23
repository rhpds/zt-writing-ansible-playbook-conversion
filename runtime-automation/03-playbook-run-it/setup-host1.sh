#!/bin/sh
# Module 03: provide the playbook that learners run in this module.
set -eu

. /tmp/runtime-scripts/runtime-helper.sh

install -d -o "${LAB_USER}" -g "${LAB_USER}" -m 0755 "${LAB_WORKSPACE}"
cat > "${LAB_WORKSPACE}/system_setup.yml" <<'EOF'
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
chown "${LAB_USER}:${LAB_USER}" "${LAB_WORKSPACE}/system_setup.yml"
chmod 0644 "${LAB_WORKSPACE}/system_setup.yml"

echo "Module 03 setup complete."
