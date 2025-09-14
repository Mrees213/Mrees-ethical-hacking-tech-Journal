#!/usr/bin/env bash
# This line specifies the shell interpreter to use (bash in this case).

# Usage message: This script scans a range of IP addresses (from .1 to .254) in the given network prefix.
# It checks if a specific port (e.g., port 53 for DNS) is open for each IP in the range.

set -euo pipefail
# This ensures the script exits if:
#   - A command fails (set -e),
#   - An undefined variable is used (set -u),
#   - A command in a pipeline fails (pipefail).

PREFIX="${1:-}"
PORT="${2:-}"
# The first argument is assigned to `PREFIX`, the second to `PORT`.
# If either is not provided, they are set to empty by default.

if [[ -z "$PREFIX" || -z "$PORT" ]]; then
  # Check if either the prefix or the port is empty.
  echo "Usage: $0 <net-prefix-like-10.0.5> <port>" >&2
  # If arguments are missing, print the usage message.
  exit 1
  # Exit with status 1 indicating an error.
fi

for i in $(seq 1 254); do
  # Loop through IP addresses from .1 to .254 in the provided network prefix (e.g., 10.0.5.1 to 10.0.5.254).
  host="${PREFIX}.${i}"
  # Construct the full IP address by appending the current iteration number to the prefix.

  # Perform a TCP connection check using bash's built-in `/dev/tcp` functionality.
  # The `timeout 1` command limits the connection attempt to 1 second.
  # If the connection to the specified host and port succeeds, the script prints the result.
  if timeout 1 bash -c ">/dev/tcp/${host}/${PORT}" 2>/dev/null; then
    # If the TCP connection succeeds (i.e., the port is open), print the host and port status as OPEN.
    echo "${host} tcp/${PORT} OPEN"
  fi
done
# End of the loop: The script continues to the next IP in the range.
