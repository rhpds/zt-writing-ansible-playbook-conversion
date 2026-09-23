#!/bin/sh
# Shared helpers for runtime-automation scripts. This file is copied to the
# control host by runtime-automation/main.yml before a stage script runs.

LAB_USER="${LAB_USER:-rhel}"
LAB_HOME="/home/${LAB_USER}"
LAB_WORKSPACE="${LAB_HOME}/ansible-files"
LAB_RUNTIME_DIR="/run/user/$(id -u "${LAB_USER}")"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_file() {
  [ -f "$1" ] || fail "Required file does not exist: $1"
}

require_directory() {
  [ -d "$1" ] || fail "Required directory does not exist: $1"
}

run_navigator() {
  playbook="$1"

  require_file "${playbook}"

  runuser -u "${LAB_USER}" -- env \
    HOME="${LAB_HOME}" \
    XDG_RUNTIME_DIR="${LAB_RUNTIME_DIR}" \
    sh -c '
      cd "$1" || exit 1
      if command -v ansible-navigator >/dev/null 2>&1; then
        exec ansible-navigator run "$2" --mode stdout
      fi
      if command -v ansible-playbook >/dev/null 2>&1; then
        exec ansible-playbook "$2"
      fi
      echo "Neither ansible-navigator nor ansible-playbook is installed." >&2
      exit 127
    ' sh "${LAB_WORKSPACE}" "${playbook}"
}
