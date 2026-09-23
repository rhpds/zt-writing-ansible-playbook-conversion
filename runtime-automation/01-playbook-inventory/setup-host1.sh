#!/bin/sh
# Module 01: prepare the learner's Ansible Navigator workspace.
set -eu

. /tmp/runtime-scripts/runtime-helper.sh

LOG_DIR="${LAB_HOME}/.logs"
NAVIGATOR_IMAGE="${ANSIBLE_NAVIGATOR_EE_IMAGE:-quay.io/acme_corp/first_playbook_ee:latest}"

install -d -o "${LAB_USER}" -g "${LAB_USER}" -m 0755 "${LAB_WORKSPACE}" "${LOG_DIR}"

printf '%s\n' \
  '[defaults]' \
  "inventory = ${LAB_WORKSPACE}/inventory" \
  'host_key_checking = False' \
  > "${LAB_HOME}/.ansible.cfg"

printf '%s\n' \
  '[user]' \
  "  email = ${LAB_USER}@example.com" \
  '  name = Red Hat' \
  > "${LAB_HOME}/.gitconfig"

printf '%s\n' \
  '---' \
  'ansible-navigator:' \
  '  ansible:' \
  '    inventory:' \
  '      entries:' \
  "        - ${LAB_WORKSPACE}/inventory" \
  '  execution-environment:' \
  '    container-engine: podman' \
  '    enabled: true' \
  "    image: ${NAVIGATOR_IMAGE}" \
  '    pull:' \
  '      policy: missing' \
  '  logging:' \
  '    level: debug' \
  "    file: ${LOG_DIR}/ansible-navigator.log" \
  '  mode: stdout' \
  '  playbook-artifact:' \
  "    save-as: ${LOG_DIR}/{playbook_name}-artifact-{time_stamp}.json" \
  > "${LAB_WORKSPACE}/ansible-navigator.yml"

cp "${LAB_WORKSPACE}/ansible-navigator.yml" "${LAB_HOME}/.ansible-navigator.yml"
chown "${LAB_USER}:${LAB_USER}" \
  "${LAB_HOME}/.ansible.cfg" \
  "${LAB_HOME}/.gitconfig" \
  "${LAB_HOME}/.ansible-navigator.yml" \
  "${LAB_WORKSPACE}/ansible-navigator.yml"
chmod 0644 \
  "${LAB_HOME}/.ansible.cfg" \
  "${LAB_HOME}/.gitconfig" \
  "${LAB_HOME}/.ansible-navigator.yml" \
  "${LAB_WORKSPACE}/ansible-navigator.yml"

echo "Module 01 setup complete: ${LAB_WORKSPACE} is ready."
