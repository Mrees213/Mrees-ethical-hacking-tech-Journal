#!/usr/bin/env bash
# Usage: ./scan24.sh 10.0.5 53
set -euo pipefail
PREFIX="${1:-}"
PORT="${2:-}"
if [[ -z "$PREFIX" || -z "$PORT" ]]; then
  echo "Usage: $0 <net-prefix-like-10.0.5> <port>" >&2
  exit 1
fi

for i in $(seq 1 254); do
  host="${PREFIX}.${i}"
  # bash built-in TCP connect with 1s timeout
  if timeout 1 bash -c ">/dev/tcp/${host}/${PORT}" 2>/dev/null; then
    echo "${host} tcp/${PORT} OPEN"
  fi
done


