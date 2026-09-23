#!/bin/sh
# This script runs as root on host1 during lab provisioning.
set -eu

LAB_USER="rhel"
LAB_HOME="/home/${LAB_USER}"
WORKSPACE="${LAB_HOME}/ansible-files"
LOG_DIR="${LAB_HOME}/.logs"
CODE_SERVER_VERSION="${CODE_SERVER_VERSION:-4.138.0}"
CODE_SERVER_PASSWORD="${CODE_SERVER_PASSWORD:-ansible123!}"
ANSIBLE_NAVIGATOR_EE_IMAGE="${ANSIBLE_NAVIGATOR_EE_IMAGE:-quay.io/acme_corp/first_playbook_ee:latest}"

echo "Creating the Ansible learner workspace"
install -d -o "${LAB_USER}" -g "${LAB_USER}" -m 0755 "${WORKSPACE}" "${LOG_DIR}"

printf '%s\n' \
  '[defaults]' \
  "inventory = ${WORKSPACE}/inventory" \
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
  "        - ${WORKSPACE}/inventory" \
  '  execution-environment:' \
  '    container-engine: podman' \
  '    enabled: true' \
  "    image: ${ANSIBLE_NAVIGATOR_EE_IMAGE}" \
  '    pull:' \
  '      policy: missing' \
  '  logging:' \
  '    level: debug' \
  "    file: ${LOG_DIR}/ansible-navigator.log" \
  '  mode: stdout' \
  '  playbook-artifact:' \
  "    save-as: ${LOG_DIR}/{playbook_name}-artifact-{time_stamp}.json" \
  > "${WORKSPACE}/ansible-navigator.yml"

cp "${WORKSPACE}/ansible-navigator.yml" "${LAB_HOME}/.ansible-navigator.yml"
chown "${LAB_USER}:${LAB_USER}" \
  "${LAB_HOME}/.ansible.cfg" \
  "${LAB_HOME}/.gitconfig" \
  "${LAB_HOME}/.ansible-navigator.yml" \
  "${WORKSPACE}/ansible-navigator.yml"
chmod 0644 \
  "${LAB_HOME}/.ansible.cfg" \
  "${LAB_HOME}/.gitconfig" \
  "${LAB_HOME}/.ansible-navigator.yml" \
  "${WORKSPACE}/ansible-navigator.yml"

if ! command -v code-server >/dev/null 2>&1; then
  case "$(uname -m)" in
    x86_64)
      CODE_SERVER_ARCH="amd64"
      ;;
    *)
      echo "Unsupported architecture for code-server: $(uname -m)" >&2
      exit 1
      ;;
  esac

  CODE_SERVER_RPM="/var/tmp/code-server-${CODE_SERVER_VERSION}-${CODE_SERVER_ARCH}.rpm"
  CODE_SERVER_URL="https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-${CODE_SERVER_ARCH}.rpm"

  echo "Installing code-server ${CODE_SERVER_VERSION}"
  curl --fail --location --retry 3 --output "${CODE_SERVER_RPM}" "${CODE_SERVER_URL}"
  rpm -Uvh "${CODE_SERVER_RPM}"
  rm -f "${CODE_SERVER_RPM}"
fi

echo "Configuring code-server for ${LAB_USER}"
install -d -o "${LAB_USER}" -g "${LAB_USER}" -m 0700 "${LAB_HOME}/.config/code-server"
printf '%s\n' \
  'bind-addr: 0.0.0.0:8080' \
  'auth: password' \
  "password: ${CODE_SERVER_PASSWORD}" \
  'cert: false' \
  > "${LAB_HOME}/.config/code-server/config.yaml"
chown "${LAB_USER}:${LAB_USER}" "${LAB_HOME}/.config/code-server/config.yaml"
chmod 0600 "${LAB_HOME}/.config/code-server/config.yaml"

# Keep the user service alive after the provisioning connection closes.
loginctl enable-linger 
systemctl enable --now code-server
systemctl restart code-server
systemctl --no-pager --full status code-server

echo "code-server is listening on host1 TCP/8080 with ${WORKSPACE} ready to open."
echo "A CNV route or proxy is still required before the Showroom browser tab can reach it."

