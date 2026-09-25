#!/bin/bash
set -euo pipefail

cd /home/rhel/ansible-files
ansible-navigator run system_setup.yml

echo "Ran system_setup.yml."
