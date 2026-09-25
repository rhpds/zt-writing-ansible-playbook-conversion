#!/bin/bash
set -euo pipefail

WORKSPACE=/home/rhel/ansible-files

runuser -u rhel -- mkdir -p \
  "$WORKSPACE/roles/apache/tasks" \
  "$WORKSPACE/roles/apache/handlers" \
  "$WORKSPACE/roles/apache/templates" \
  "$WORKSPACE/roles/apache/vars"

runuser -u rhel -- tee "$WORKSPACE/roles/apache/vars/main.yml" > /dev/null <<'EOF'
---
apache_package_name: httpd
apache_service_name: httpd
EOF

runuser -u rhel -- tee "$WORKSPACE/roles/apache/tasks/main.yml" > /dev/null <<'EOF'
---
- name: Install Apache web server
  ansible.builtin.package:
    name: "{{ apache_package_name }}"
    state: present

- name: Ensure Apache is running and enabled
  ansible.builtin.service:
    name: "{{ apache_service_name }}"
    state: started
    enabled: true

- name: Install firewalld
  ansible.builtin.dnf:
    name: firewalld
    state: present

- name: Ensure firewalld is running
  ansible.builtin.service:
    name: firewalld
    state: started
    enabled: true

- name: Allow HTTP traffic on web servers
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

runuser -u rhel -- tee "$WORKSPACE/roles/apache/handlers/main.yml" > /dev/null <<'EOF'
---
- name: Reload Firewall
  ansible.builtin.service:
    name: firewalld
    state: reloaded
EOF

runuser -u rhel -- tee "$WORKSPACE/roles/apache/templates/index.html.j2" > /dev/null <<'EOF'
<html>
<head>
<title>Welcome to {{ ansible_hostname }}</title>
</head>
<body>
  <h1>Hello from {{ ansible_hostname }}</h1>
</body>
</html>
EOF

runuser -u rhel -- tee "$WORKSPACE/deploy_apache.yml" > /dev/null <<'EOF'
---
- name: Setup Apache Web Servers
  hosts: web
  become: true
  roles:
    - apache
EOF

runuser -u rhel -- env HOME=/home/rhel XDG_RUNTIME_DIR="/run/user/$(id -u rhel)" \
  bash -c "cd \"$WORKSPACE\" && ansible-navigator run deploy_apache.yml --mode stdout"

echo "Created and applied the apache role."
