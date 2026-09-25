#!/bin/sh
# This script runs as root on host1 during lab provisioning.
set -eu

LAB_USER="rhel"
LAB_HOME="/home/${LAB_USER}"
WORKSPACE="${LAB_HOME}/ansible-files"
SSH_DIR="${LAB_HOME}/.ssh"
SSH_PRIVATE_KEY="${SSH_DIR}/id_rsa"
SSH_PUBLIC_KEY="${SSH_PRIVATE_KEY}.pub"
NODE_HOSTS="node1 node2 node3"
NODE_PASSWORD="${NODE_PASSWORD:-ansible123!}"
LOG_DIR="${LAB_HOME}/.logs"
CODE_SERVER_VERSION="${CODE_SERVER_VERSION:-4.138.0}"
CODE_SERVER_PASSWORD="${CODE_SERVER_PASSWORD:-ansible123!}"
ANSIBLE_NAVIGATOR_EE_IMAGE="${ANSIBLE_NAVIGATOR_EE_IMAGE:-quay.io/acme_corp/first_playbook_ee:latest}"

configure_ssh_key_authentication() {
  echo "Creating an SSH key for ${LAB_USER}"
  install -d -o "${LAB_USER}" -g "${LAB_USER}" -m 0700 "${SSH_DIR}"
  chown "${LAB_USER}:${LAB_USER}" "${SSH_DIR}"
  chmod 0700 "${SSH_DIR}"

  if [ ! -f "${SSH_PRIVATE_KEY}" ]; then
    runuser -u "${LAB_USER}" -- ssh-keygen -q -t rsa -b 4096 -N '' -f "${SSH_PRIVATE_KEY}"
  fi

  if [ ! -f "${SSH_PUBLIC_KEY}" ]; then
    runuser -u "${LAB_USER}" -- sh -c 'ssh-keygen -y -f "$1" > "$2"' sh \
      "${SSH_PRIVATE_KEY}" "${SSH_PUBLIC_KEY}"
  fi

  chown "${LAB_USER}:${LAB_USER}" "${SSH_PRIVATE_KEY}" "${SSH_PUBLIC_KEY}"
  chmod 0600 "${SSH_PRIVATE_KEY}"
  chmod 0644 "${SSH_PUBLIC_KEY}"

  # SSH_ASKPASS supplies the cloud-init password only while the public key is
  # installed. All later connections are verified with the new key.
  SSH_ASKPASS_SCRIPT="$(mktemp /tmp/${LAB_USER}-ssh-askpass.XXXXXX)"
  trap 'rm -f "${SSH_ASKPASS_SCRIPT}"' EXIT HUP INT TERM
  printf '%s\n' \
    '#!/bin/sh' \
    'printf "%s\\n" "$SSH_ASKPASS_PASSWORD"' \
    > "${SSH_ASKPASS_SCRIPT}"
  chown "${LAB_USER}:${LAB_USER}" "${SSH_ASKPASS_SCRIPT}"
  chmod 0700 "${SSH_ASKPASS_SCRIPT}"

  for NODE_HOST in ${NODE_HOSTS}; do
    echo "Installing ${LAB_USER}'s public key on ${NODE_HOST}"
    runuser -u "${LAB_USER}" -- env \
      HOME="${LAB_HOME}" \
      DISPLAY=none \
      SSH_ASKPASS="${SSH_ASKPASS_SCRIPT}" \
      SSH_ASKPASS_REQUIRE=force \
      SSH_ASKPASS_PASSWORD="${NODE_PASSWORD}" \
      setsid ssh \
        -o BatchMode=no \
        -o ConnectTimeout=15 \
        -o NumberOfPasswordPrompts=1 \
        -o PreferredAuthentications=password \
        -o PubkeyAuthentication=no \
        -o StrictHostKeyChecking=accept-new \
        "${LAB_USER}@${NODE_HOST}" \
        'install -d -m 700 "$HOME/.ssh"; authorized_keys="$HOME/.ssh/authorized_keys"; touch "$authorized_keys"; chmod 600 "$authorized_keys"; IFS= read -r public_key; if ! grep -qxF "$public_key" "$authorized_keys"; then printf "%s\\n" "$public_key" >> "$authorized_keys"; fi' \
        < "${SSH_PUBLIC_KEY}"

    runuser -u "${LAB_USER}" -- env HOME="${LAB_HOME}" \
      ssh -i "${SSH_PRIVATE_KEY}" \
        -o BatchMode=yes \
        -o ConnectTimeout=15 \
        -o StrictHostKeyChecking=accept-new \
        "${LAB_USER}@${NODE_HOST}" true
  done
}

echo "Creating the Ansible learner workspace"
install -d -o "${LAB_USER}" -g "${LAB_USER}" -m 0755 "${WORKSPACE}" "${LOG_DIR}"
configure_ssh_key_authentication

# The system-level configuration is useful for native Ansible commands. The
# inventory uses an absolute path because this file lives outside the workspace.
install -d -m 0755 /etc/ansible
printf '%s\n' \
  '[defaults]' \
  "inventory = ${WORKSPACE}/inventory" \
  "remote_user = ${LAB_USER}" \
  'host_key_checking = False' \
  "private_key_file = ${SSH_PRIVATE_KEY}" \
  > /etc/ansible/ansible.cfg

printf '%s\n' \
  '[defaults]' \
  "inventory = ${WORKSPACE}/inventory" \
  "remote_user = ${LAB_USER}" \
  'host_key_checking = False' \
  "private_key_file = ${SSH_PRIVATE_KEY}" \
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
  '    environment-variables:' \
  '      set:' \
  "        ANSIBLE_REMOTE_USER: ${LAB_USER}" \
  "        ANSIBLE_PRIVATE_KEY_FILE: ${SSH_PRIVATE_KEY}" \
  "        ANSIBLE_HOST_KEY_CHECKING: 'False'" \
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

# Keep Ansible extension settings outside the learner workspace. In particular,
# disabling validation prevents ansible-lint from creating .ansible directories
# next to the lesson files.
VSCODE_USER_DIR="${LAB_HOME}/.local/share/code-server/User"
install -d -o "${LAB_USER}" -g "${LAB_USER}" -m 0700 "${VSCODE_USER_DIR}"
printf '%s\n' \
  '{' \
  '  "ansible.python.interpreterPath": "/usr/bin/python3",' \
  '  "ansible.validation.enabled": false,' \
  '  "ansible.validation.lint.enabled": false,' \
  '  "security.workspace.trust.enabled": false' \
  '}' \
  > "${VSCODE_USER_DIR}/settings.json"
chown "${LAB_USER}:${LAB_USER}" "${VSCODE_USER_DIR}/settings.json"
chmod 0600 "${VSCODE_USER_DIR}/settings.json"

# Keep the user service alive after the provisioning connection closes.
loginctl enable-linger 
systemctl enable --now code-server
systemctl restart code-server
systemctl --no-pager --full status code-server

echo "code-server is listening on host1 TCP/8080 with ${WORKSPACE} ready to open."
echo "A CNV route or proxy is still required before the Showroom browser tab can reach it."
