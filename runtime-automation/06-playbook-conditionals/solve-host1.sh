#!/bin/bash
set -euo pipefail

tee /home/rhel/ansible-files/inventory > /dev/null <<'EOF'
[web]
node1
node2

[database]
node3
EOF

tee /home/rhel/ansible-files/system_setup.yml > /dev/null <<'EOF'
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

cd /home/rhel/ansible-files
ansible-navigator run system_setup.yml

echo "Added database hosts and web-only Apache installation."
