#!/bin/sh
# Module 06: Playbook Conditionals - Solve
# Creates playbook with conditionals and updates inventory
set -eu

. /tmp/runtime-scripts/runtime-helper.sh
USER="${LAB_USER}"

# Update inventory to add database group
cat > /home/${USER}/ansible-files/inventory <<'EOF'
[web]
node1
node2

[database]
node3
EOF

# Create the system_setup.yml playbook with conditionals
cat > /home/${USER}/ansible-files/system_setup.yml <<'EOF'
---
- name: Basic System Setup
  hosts: all
  become: true
  vars:
    user_name: 'padawan'
    package_name: httpd
  tasks:
    - name: Install security updates for the kernel
      ansible.builtin.dnf:
        name: 'kernel'
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

# Set proper ownership
chown ${USER}:${USER} /home/${USER}/ansible-files/inventory
chown ${USER}:${USER} /home/${USER}/ansible-files/system_setup.yml
chmod 0644 /home/${USER}/ansible-files/inventory
chmod 0644 /home/${USER}/ansible-files/system_setup.yml

echo "Created system_setup.yml playbook with conditionals and updated inventory"
run_navigator "${LAB_WORKSPACE}/system_setup.yml"
