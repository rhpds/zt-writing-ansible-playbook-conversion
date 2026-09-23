#!/bin/sh
# Module 02: reset the inventory used to build the first playbook.
set -eu

. /tmp/runtime-scripts/runtime-helper.sh

install -d -o "${LAB_USER}" -g "${LAB_USER}" -m 0755 "${LAB_WORKSPACE}"
printf '%s\n' \
  '[web]' \
  'node1' \
  'node2' \
  > "${LAB_WORKSPACE}/inventory"
chown "${LAB_USER}:${LAB_USER}" "${LAB_WORKSPACE}/inventory"
chmod 0644 "${LAB_WORKSPACE}/inventory"

echo "Module 02 setup complete."
