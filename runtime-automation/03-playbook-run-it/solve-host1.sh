#!/bin/bash
set -euo pipefail

WORKSPACE=/home/rhel/ansible-files

runuser -u rhel -- env HOME=/home/rhel XDG_RUNTIME_DIR="/run/user/$(id -u rhel)" \
  bash -c "cd \"$WORKSPACE\" && ansible-navigator run system_setup.yml --mode stdout"

echo "Ran system_setup.yml."
