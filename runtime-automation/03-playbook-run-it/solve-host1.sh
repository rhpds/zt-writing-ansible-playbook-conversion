#!/bin/bash
set -euo pipefail

. /tmp/runtime-scripts/runtime-helper.sh

run_navigator system_setup.yml

echo "Ran system_setup.yml."
