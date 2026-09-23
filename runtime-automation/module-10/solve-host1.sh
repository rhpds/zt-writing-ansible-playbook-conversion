#!/bin/sh
# Module 10: Roles - Solve
# Creates Apache role structure and deploys it
set -eu

. /tmp/runtime-scripts/runtime-helper.sh
USER="${LAB_USER}"

# Remove and recreate roles directory
rm -rf /home/${USER}/ansible-files/roles
mkdir -p /home/${USER}/ansible-files/roles

# Initialize apache role structure using ansible-galaxy
cd /home/${USER}/ansible-files/roles
ansible-galaxy init --offline apache

# Create role variables
cat > /home/${USER}/ansible-files/roles/apache/vars/main.yml <<'EOF'
---
# vars file for apache
apache_package_name: httpd
apache_service_name: httpd
EOF

# Create role tasks
cat > /home/${USER}/ansible-files/roles/apache/tasks/main.yml <<'EOF'
---
# tasks file for apache
- name: Install Apache
  ansible.builtin.dnf:
    name: "{{ apache_package_name }}"
    state: present

- name: Start and enable Apache service
  ansible.builtin.service:
    name: "{{ apache_service_name }}"
    state: started
    enabled: true

- name: Install firewalld
  ansible.builtin.dnf:
    name: firewalld
    state: present

- name: Start and enable firewalld
  ansible.builtin.service:
    name: firewalld
    state: started
    enabled: true

- name: Allow HTTP traffic
  ansible.posix.firewalld:
    service: http
    permanent: true
    state: enabled
  notify: Reload Firewall

- name: Deploy custom index.html
  ansible.builtin.template:
    src: index.html.j2
    dest: /var/www/html/index.html
EOF

# Create role handlers
cat > /home/${USER}/ansible-files/roles/apache/handlers/main.yml <<'EOF'
---
# handlers file for apache
- name: Reload Firewall
  ansible.builtin.service:
    name: firewalld
    state: reloaded
EOF

# Create role template
cat > /home/${USER}/ansible-files/roles/apache/templates/index.html.j2 <<'EOF'
<html>
<head>
<title>Welcome to {{ ansible_hostname }}</title>
</head>
<body>
<h1>Hello from {{ ansible_hostname }}</h1>
</body>
</html>
EOF

# Create deploy_apache.yml playbook
cat > /home/${USER}/ansible-files/deploy_apache.yml <<'EOF'
---
- name: Deploy Apache using role
  hosts: web
  become: true
  roles:
    - apache
EOF

# Set proper ownership recursively
chown -R ${USER}:${USER} /home/${USER}/ansible-files/roles
chown ${USER}:${USER} /home/${USER}/ansible-files/deploy_apache.yml
chmod 0644 /home/${USER}/ansible-files/deploy_apache.yml

echo "Created Apache role and deploy_apache.yml playbook"
run_navigator "${LAB_WORKSPACE}/deploy_apache.yml"
