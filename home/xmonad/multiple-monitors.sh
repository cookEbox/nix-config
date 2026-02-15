#!/usr/bin/env sh

# Multi-monitor layout helper for XMonad.
#
# This script is intentionally host-agnostic:
# - It auto-detects connected outputs via xrandr
# - It supports overriding outputs via environment variables:
#   - XRANDR_PRIMARY
#   - XRANDR_SECONDARY
#
# Default behaviour:
# - If 2+ outputs are connected: enable the first as primary, place the second to the right
# - Disable any other connected outputs
# - If only 1 output is connected: enable it as primary

set -eu

if ! command -v xrandr >/dev/null 2>&1; then
  exit 0
fi

connected_outputs() {
  # Print connected outputs, one per line.
  xrandr --query | awk '/\sconnected/{print $1}'
}

outputs="$(connected_outputs || true)"

primary="${XRANDR_PRIMARY:-$(printf '%s\n' "$outputs" | sed -n '1p')}"
secondary="${XRANDR_SECONDARY:-$(printf '%s\n' "$outputs" | sed -n '2p')}"

# Nothing connected? Nothing to do.
if [ -z "${primary:-}" ]; then
  exit 0
fi

cmd="xrandr --output $primary --primary --auto"

if [ -n "${secondary:-}" ] && [ "$secondary" != "$primary" ]; then
  cmd="$cmd --output $secondary --auto --right-of $primary"
fi

# Disable any other connected outputs.
for out in $outputs; do
  if [ "$out" != "$primary" ] && [ -n "${secondary:-}" ] && [ "$out" != "$secondary" ]; then
    cmd="$cmd --output $out --off"
  fi
  if [ "$out" != "$primary" ] && [ -z "${secondary:-}" ]; then
    cmd="$cmd --output $out --off"
  fi
done

# shellcheck disable=SC2086
$cmd
