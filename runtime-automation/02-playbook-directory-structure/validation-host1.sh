#!/bin/bash
set -euo pipefail

test -f /home/rhel/ansible-files/system_setup.yml
grep -qx -- '---' /home/rhel/ansible-files/system_setup.yml
grep -qx -- '- name: Basic System Setup' /home/rhel/ansible-files/system_setup.yml
grep -qx -- '  hosts: node1' /home/rhel/ansible-files/system_setup.yml
grep -qx -- '  become: true' /home/rhel/ansible-files/system_setup.yml
grep -qx -- '    - name: Install security updates for the kernel' /home/rhel/ansible-files/system_setup.yml
grep -qx -- '      ansible.builtin.dnf:' /home/rhel/ansible-files/system_setup.yml
grep -qx -- '        name: kernel' /home/rhel/ansible-files/system_setup.yml
grep -qx -- '        state: latest' /home/rhel/ansible-files/system_setup.yml
grep -qx -- '        security: true' /home/rhel/ansible-files/system_setup.yml
grep -qx -- '    - name: Create a new user' /home/rhel/ansible-files/system_setup.yml
grep -qx -- '      ansible.builtin.user:' /home/rhel/ansible-files/system_setup.yml
grep -qx -- '        name: myuser' /home/rhel/ansible-files/system_setup.yml
grep -qx -- '        state: present' /home/rhel/ansible-files/system_setup.yml
grep -qx -- '        create_home: true' /home/rhel/ansible-files/system_setup.yml

echo "Module 02 validation passed."
