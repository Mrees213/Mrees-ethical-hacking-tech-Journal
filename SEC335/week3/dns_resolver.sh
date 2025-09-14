#!/usr/bin/env bash
# This line specifies the shell interpreter to use (bash in this case).

# Usage message: this script resolves PTR (reverse DNS) lookups for a given IP range.
# The script takes two arguments: 
#   1. A prefix for the IP address range (e.g., "10.0.5" for 10.0.5.1 - 10.0.5.254).
#   2. The DNS server to query (e.g., "10.0.5.22").

set -euo pipefail
# This ensures the script exits if:
#   - A command fails (set -e),
#   - An undefined variable is used (set -u),
#   - A command in a pipeline fails (pipefail).

prefix="${1:-}"; server="${2:-}"
# The first argument is assigned to `prefix`, the second to `server`.
# If either is not provided, they are set to empty by default.

if [[ -z "${prefix}" || -z "${server}" ]]; then
  # Check if either the prefix or the server is empty.
  echo "Usage: $0 <prefix like 10.0.5> <dns-server>" >&2; exit 1
  # If arguments are missing, print the usage message and exit with status 1.
fi

out="reverse_${prefix}_via_${server//./-}.csv"
# Construct the output file name using the prefix and server, replacing periods with hyphens in the server address.
echo "ip,hostname" > "$out"
# Write the CSV header ("ip,hostname") to the output file.

for i in {1..254}; do
  # Loop through IP addresses 10.0.5.1 to 10.0.5.254 (replace "10.0.5" with the given prefix).
  ip="${prefix}.${i}"
  # Assign the IP address by appending the counter to the prefix.

  # Lab note: Skip scanning 10.0.5.2 if the prefix is "10.0.5" (this is specific to the lab setup).
  if [[ "$prefix" == "10.0.5" && "$ip" == "10.0.5.2" ]]; then
    continue
    # If the current IP is 10.0.5.2, skip it and go to the next iteration.
  fi

  # Perform a PTR lookup (reverse DNS) first with UDP (default).
  name="$(dig -x "$ip" @"$server" +short +time=1 +tries=1 | sed 's/\.$//')"
  # The `dig` command queries the specified DNS server for the PTR record of the IP.
  # `+short` returns a short, clean result (hostname).
  # `+time=1` sets the query timeout to 1 second.
  # `+tries=1` limits the number of retries to 1.
  # `sed 's/\.$//'` removes any trailing period from the result.

  # If the UDP lookup doesn't return a result, try TCP fallback.
  if [[ -z "$name" ]]; then
    # If the name is empty, perform the same lookup but with TCP.
    name="$(dig -x "$ip" @"$server" +short +time=1 +tries=1 +tcp | sed 's/\.$//')"
    # `+tcp` forces the query to use TCP instead of UDP.
  fi

  # If a name was found (i.e., the PTR lookup succeeded):
  if [[ -n "$name" ]]; then
    echo "$ip,$name" | tee -a "$out"
    # Print the IP address and resolved hostname to the screen and append it to the output file.
  fi
done

echo "Saved to $out"
# Print the location of the saved CSV file containing the IP-to-hostname mappings.
