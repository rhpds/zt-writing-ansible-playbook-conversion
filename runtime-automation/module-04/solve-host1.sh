#!/bin/sh
# Module 04: Playbook Multi Node - Solve
# Creates the system_setup.yml playbook and executes it on web nodes

USER="rhel"

# Create the system_setup.yml playbook file
cat > /home/${USER}/ansible-files/system_setup.yml <<'EOF'
---
- name: Basic System Setup
  hosts: web
  become: true
  tasks:
    - name: Install security updates for the kernel
      ansible.builtin.dnf:
        name: 'kernel'
        state: latest
        security: true

    - name: Create a new user
      ansible.builtin.user:
        name: myuser
        state: present
        create_home: true
EOF

# Set proper ownership
chown ${USER}:${USER} /home/${USER}/ansible-files/system_setup.yml
chmod 0644 /home/${USER}/ansible-files/system_setup.yml

echo "Created system_setup.yml playbook for multi-node deployment"
