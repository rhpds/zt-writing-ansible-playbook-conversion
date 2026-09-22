#!/bin/sh
# Module 09: Playbook Templates - Solve
# Creates Jinja2 template and playbook using templates

USER="rhel"

# Create templates directory
mkdir -p /home/${USER}/ansible-files/templates
chown ${USER}:${USER} /home/${USER}/ansible-files/templates
chmod 0755 /home/${USER}/ansible-files/templates

# Create the motd.j2 template
cat > /home/${USER}/ansible-files/templates/motd.j2 <<'EOF'
Welcome to {{ ansible_hostname }}.
OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
Architecture: {{ ansible_architecture }}
EOF

# Create the system_setup.yml playbook with template task
cat > /home/${USER}/ansible-files/system_setup.yml <<'EOF'
---
- name: Basic System Setup
  hosts: all
  become: true
  vars:
    user_name: 'padawan'
    package_name: httpd
    apache_service_name: httpd
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

    - name: Ensure Apache is running and enabled
      ansible.builtin.service:
        name: "{{ apache_service_name }}"
        state: started
        enabled: true
      when: inventory_hostname in groups['web']

    - name: Install firewalld
      ansible.builtin.dnf:
        name: firewalld
        state: present
      when: inventory_hostname in groups['web']

    - name: Ensure firewalld is running
      ansible.builtin.service:
        name: firewalld
        state: started
        enabled: true
      when: inventory_hostname in groups['web']

    - name: Allow HTTP traffic on web servers
      ansible.posix.firewalld:
        service: http
        permanent: true
        state: enabled
      when: inventory_hostname in groups['web']
      notify: Reload Firewall

    - name: Update MOTD from Jinja2 Template
      ansible.builtin.template:
        src: templates/motd.j2
        dest: /etc/motd

  handlers:
    - name: Reload Firewall
      ansible.builtin.service:
        name: firewalld
        state: reloaded
EOF

# Set proper ownership
chown ${USER}:${USER} /home/${USER}/ansible-files/templates/motd.j2
chown ${USER}:${USER} /home/${USER}/ansible-files/system_setup.yml
chmod 0644 /home/${USER}/ansible-files/templates/motd.j2
chmod 0644 /home/${USER}/ansible-files/system_setup.yml

echo "Created motd.j2 template and system_setup.yml playbook"
