#!/bin/bash
set -euo pipefail

. /tmp/runtime-scripts/runtime-helper.sh

write_workspace_file inventory <<'EOF'
[web]
node1
node2

[database]
node3
EOF

write_workspace_file system_setup.yml <<'EOF'
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

run_navigator system_setup.yml

echo "Added database hosts and web-only Apache installation."
