#!/bin/sh
# Module 08: Playbook Loops - Solve
# Creates playbook with loops for multiple users

USER="rhel"

# Create the loop_users.yml playbook with loops
cat > /home/${USER}/ansible-files/loop_users.yml <<'EOF'
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

# Set proper ownership
chown ${USER}:${USER} /home/${USER}/ansible-files/loop_users.yml
chmod 0644 /home/${USER}/ansible-files/loop_users.yml

echo "Created loop_users.yml playbook with loops"
