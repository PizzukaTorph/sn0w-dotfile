#!/usr/bin/env bash
set -euo pipefail

PROFILE="${1:-vm}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$PROFILE" in
  vm|asahi) ;;
  *)
    echo "Usage: $0 [vm|asahi]" >&2
    exit 2
    ;;
esac

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required." >&2
  exit 1
fi

if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "[sn0w] installing Ansible..."
  sudo dnf install -y ansible-core
fi

echo "[sn0w] provisioning profile: ${PROFILE}"
ansible-playbook \
  -i "${ROOT_DIR}/ansible/inventory.yml" \
  "${ROOT_DIR}/ansible/playbook.yml" \
  -e "sn0w_profile=${PROFILE}" \
  -K
