#!/bin/sh
# Module 05: Playbook Variables - Solve
# Creates a playbook that uses variables
set -eu

. /tmp/runtime-scripts/runtime-helper.sh
USER="${LAB_USER}"

# Create the system_setup.yml playbook file with variables
cat > /home/${USER}/ansible-files/system_setup.yml <<'EOF'
---
- name: Basic System Setup
  hosts: web
  become: true
  vars:
    user_name: 'padawan'
  tasks:
    - name: Install security updates for the kernel
      ansible.builtin.dnf:
        name: 'kernel'
        state: latest
        security: true

    - name: Create a new user
      ansible.builtin.user:
        name: "{{ user_name }}"
        state: present
        create_home: true
EOF

# Set proper ownership
chown ${USER}:${USER} /home/${USER}/ansible-files/system_setup.yml
chmod 0644 /home/${USER}/ansible-files/system_setup.yml

echo "Created system_setup.yml playbook with variables"
run_navigator "${LAB_WORKSPACE}/system_setup.yml"
