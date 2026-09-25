#!/bin/bash
set -euo pipefail

WORKSPACE=/home/rhel/ansible-files

runuser -u rhel -- mkdir -p "$WORKSPACE/templates"

runuser -u rhel -- tee "$WORKSPACE/templates/motd.j2" > /dev/null <<'EOF'
Welcome to {{ ansible_hostname }}.
OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
Architecture: {{ ansible_architecture }}
EOF

runuser -u rhel -- tee "$WORKSPACE/system_setup.yml" > /dev/null <<'EOF'
---
- name: Basic System Setup
  hosts: all
  become: true
  vars:
    user_name: padawan
    package_name: httpd
    apache_service_name: httpd
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

    - name: Update MOTD from Jinja2 template
      ansible.builtin.template:
        src: templates/motd.j2
        dest: /etc/motd

  handlers:
    - name: Reload Firewall
      ansible.builtin.service:
        name: firewalld
        state: reloaded
EOF

runuser -u rhel -- env HOME=/home/rhel XDG_RUNTIME_DIR="/run/user/$(id -u rhel)" \
  bash -c "cd \"$WORKSPACE\" && ansible-navigator run system_setup.yml --mode stdout"

echo "Created the MOTD template and applied it."
