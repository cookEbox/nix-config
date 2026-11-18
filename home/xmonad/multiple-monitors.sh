
#!/usr/bin/env sh

# Configure XMonad monitors using XRandR.
# DP-2 runs at 2560x1440 @ 144 Hz; other outputs use automatic modes.

set -eu

command -v xrandr >/dev/null 2>&1 || exit 0

connected_outputs() {
  xrandr --query | awk '$2 == "connected" { print $1 }'
}

outputs="$(connected_outputs)"

primary="${XRANDR_PRIMARY:-$(printf '%s\n' "$outputs" | sed -n '1p')}"
secondary="${XRANDR_SECONDARY:-$(printf '%s\n' "$outputs" | sed -n '2p')}"

[ -n "$primary" ] || exit 0

# Configure the primary monitor.
set -- xrandr --output "$primary" --primary

if [ "$primary" = "DP-2" ]; then
  set -- "$@" --mode 2560x1440 --rate 143.97
else
  set -- "$@" --auto
fi

# Place the secondary monitor to the right.
if [ -n "$secondary" ] && [ "$secondary" != "$primary" ]; then
  set -- "$@" --output "$secondary"

  if [ "$secondary" = "DP-2" ]; then
    set -- "$@" --mode 2560x1440 --rate 143.97
  else
    set -- "$@" --auto
  fi

  set -- "$@" --right-of "$primary"
fi

# Disable unused connected outputs.
for out in $outputs; do
  if [ "$out" != "$primary" ] && [ "$out" != "$secondary" ]; then
    set -- "$@" --output "$out" --off
  fi
done

"$@"

