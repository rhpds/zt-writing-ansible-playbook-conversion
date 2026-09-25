#!/bin/bash
set -euo pipefail

WORKSPACE=/home/rhel/ansible-files

runuser -u rhel -- tee "$WORKSPACE/inventory" > /dev/null <<'EOF'
[web]
node1
node2

[database]
node3
EOF

runuser -u rhel -- tee "$WORKSPACE/system_setup.yml" > /dev/null <<'EOF'
---
- name: Basic System Setup
  hosts: all
  become: true
  vars:
    user_name: padawan
    package_name: httpd
  tasks:
    - name: Install security updates for the kernel
      ansible.builtin.dnf:
        name: kernel
        state: latest
        security: true
        update_only: true
      when: inventory_hostname in groups['web']

    - name: Create a new user
      ansible.builtin.user:
        name: "{{ user_name }}"
        state: present
        create_home: true

    - name: Install Apache on web servers
      ansible.builtin.dnf:
        name: "{{ package_name }}"
        state: present
      when: inventory_hostname in groups['web']
EOF

runuser -u rhel -- env HOME=/home/rhel XDG_RUNTIME_DIR="/run/user/$(id -u rhel)" \
  bash -c "cd \"$WORKSPACE\" && ansible-navigator run system_setup.yml --mode stdout"

echo "Added database hosts and web-only Apache installation."
