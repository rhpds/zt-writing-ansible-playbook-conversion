#!/bin/bash
set -euo pipefail

. /tmp/runtime-scripts/runtime-helper.sh

runuser -u rhel -- mkdir -p \
  "$LAB_WORKSPACE/roles/apache/tasks" \
  "$LAB_WORKSPACE/roles/apache/handlers" \
  "$LAB_WORKSPACE/roles/apache/templates" \
  "$LAB_WORKSPACE/roles/apache/vars"

write_workspace_file roles/apache/vars/main.yml <<'EOF'
---
apache_package_name: httpd
apache_service_name: httpd
EOF

write_workspace_file roles/apache/tasks/main.yml <<'EOF'
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

write_workspace_file roles/apache/handlers/main.yml <<'EOF'
---
- name: Reload Firewall
  ansible.builtin.service:
    name: firewalld
    state: reloaded
EOF

write_workspace_file roles/apache/templates/index.html.j2 <<'EOF'
<html>
<head>
<title>Welcome to {{ ansible_hostname }}</title>
</head>
<body>
  <h1>Hello from {{ ansible_hostname }}</h1>
</body>
</html>
EOF

write_workspace_file deploy_apache.yml <<'EOF'
---
- name: Setup Apache Web Servers
  hosts: web
  become: true
  roles:
    - apache
EOF

run_navigator deploy_apache.yml

echo "Created and applied the apache role."
