#!/usr/bin/env bash
# Usage: ./dns_resolver.sh 10.0.5 10.0.5.22
# Assumes /24; does PTR lookups via the specified DNS server.
set -euo pipefail
prefix="${1:-}"; server="${2:-}"
if [[ -z "${prefix}" || -z "${server}" ]]; then
  echo "Usage: $0 <prefix like 10.0.5> <dns-server>" >&2; exit 1
fi

out="reverse_${prefix}_via_${server//./-}.csv"
echo "ip,hostname" > "$out"

for i in {1..254}; do
  ip="${prefix}.${i}"
  # Lab note: skip firewall on 10.0.5.2 if scanning 10.0.5.0/24
  if [[ "$prefix" == "10.0.5" && "$ip" == "10.0.5.2" ]]; then
    continue
  fi

  # Try UDP first, then TCP fallback
  name="$(dig -x "$ip" @"$server" +short +time=1 +tries=1 | sed 's/\.$//')"
  if [[ -z "$name" ]]; then
    name="$(dig -x "$ip" @"$server" +short +time=1 +tries=1 +tcp | sed 's/\.$//')"
  fi

  if [[ -n "$name" ]]; then
    echo "$ip,$name" | tee -a "$out"
  fi
done

echo "Saved to $out"

