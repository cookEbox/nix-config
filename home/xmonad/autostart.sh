#!/usr/bin/env sh

# Autostart for XMonad session.
# Keep this minimal, portable, and idempotent.
# Anything host-specific (wallpapers, app launches, time sync) should live elsewhere.

set -eu

# Ensure common Nix paths are available even when X sessions don't source shell profiles.
# This helps tray apps (flameshot/volumeicon) and utilities (redshift) start reliably.
user="${USER:-$(id -un)}"
export PATH="$HOME/.nix-profile/bin:/etc/profiles/per-user/$user/bin:/run/current-system/sw/bin:$PATH"

# Basic logging to help debug startup issues.
LOG_FILE="$HOME/.xmonad/autostart.log"
mkdir -p "$(dirname "$LOG_FILE")"
exec >>"$LOG_FILE" 2>&1
echo "=== XMonad autostart: $(date -Is) ==="

run_once() {
  # Usage: run_once <process_name> <command...>
  name="$1"
  shift

  if ! command -v "$name" >/dev/null 2>&1; then
    return 0
  fi

  # Only start if not already running for this user.
  user="${USER:-$(id -un)}"

  # `pgrep -x` only matches the truncated comm name (15 chars), so it won't work for
  # long binary names like `polkit-gnome-authentication-agent-1`.
  if [ "${#name}" -le 15 ]; then
    if pgrep -u "$user" -x "$name" >/dev/null 2>&1; then
      return 0
    fi
  else
    if pgrep -u "$user" -f "$name" >/dev/null 2>&1; then
      return 0
    fi
  fi

  "$@" &
}

restart_process() {
  # Usage: restart_process <process_name> <command...>
  # Ensures the process re-registers with services that might appear after session start
  # (e.g. StatusNotifierWatcher for systray icons).
  name="$1"
  shift

  if ! command -v "$name" >/dev/null 2>&1; then
    return 0
  fi

  user="${USER:-$(id -un)}"

  # Best-effort kill existing instance.
  if [ "${#name}" -le 15 ]; then
    pkill -u "$user" -x "$name" >/dev/null 2>&1 || true
  else
    pkill -u "$user" -f "$name" >/dev/null 2>&1 || true
  fi

  "$@" &
}

wait_for_xrandr_monitors() {
  # Usage: wait_for_xrandr_monitors <min_count>
  # Helps avoid races where Eww opens windows before monitor layout is fully applied.
  min_count="$1"

  if ! command -v xrandr >/dev/null 2>&1; then
    return 0
  fi
  if ! command -v sed >/dev/null 2>&1; then
    return 0
  fi

  i=0
  while [ "$i" -lt 50 ]; do
    count="$(xrandr --listmonitors 2>/dev/null | sed -n '1s/^Monitors: //p')"
    case "$count" in
      ''|*[!0-9]*) count=0 ;;
    esac

    if [ "$count" -ge "$min_count" ]; then
      return 0
    fi

    i=$((i + 1))
    sleep 0.1
  done

  return 0
}

wait_for_dbus_session() {
  # Best-effort wait for the user session D-Bus to be responsive.
  # Eww systray + nm-applet AppIndicator docking depends on this.
  if ! command -v gdbus >/dev/null 2>&1; then
    return 0
  fi

  i=0
  while [ "$i" -lt 50 ]; do
    if gdbus call --session \
      --dest org.freedesktop.DBus \
      --object-path /org/freedesktop/DBus \
      --method org.freedesktop.DBus.ListNames \
      >/dev/null 2>&1; then
      return 0
    fi

    i=$((i + 1))
    sleep 0.1
  done

  return 0
}

wait_for_dbus_name() {
  # Usage: wait_for_dbus_name <bus_name>
  # Example: wait_for_dbus_name org.kde.StatusNotifierWatcher
  name="$1"

  if ! command -v gdbus >/dev/null 2>&1; then
    return 0
  fi

  i=0
  while [ "$i" -lt 50 ]; do
    if gdbus call --session \
      --dest org.freedesktop.DBus \
      --object-path /org/freedesktop/DBus \
      --method org.freedesktop.DBus.NameHasOwner \
      "$name" \
      2>/dev/null \
      | grep -q "true"; then
      return 0
    fi

    i=$((i + 1))
    sleep 0.1
  done

  return 0
}

# Optional multi-monitor layout (only if the helper exists and xrandr is available).
# Allow overriding outputs (useful if xrandr output ordering is not stable).
# Example:
#   XRANDR_PRIMARY=HDMI-3 XRANDR_SECONDARY=DP-2 "$HOME/.xmonad/multiple-monitors.sh"
if command -v xrandr >/dev/null 2>&1 && [ -x "$HOME/.xmonad/multiple-monitors.sh" ]; then
  XRANDR_PRIMARY="${XRANDR_PRIMARY:-HDMI-3}" \
  XRANDR_SECONDARY="${XRANDR_SECONDARY:-DP-2}" \
  "$HOME/.xmonad/multiple-monitors.sh" || true
fi

# Give XRandR a moment to settle so Eww opens on the correct monitors.
# (This avoids a race where systray windows exist on the wrong monitor and icons don't dock.)
wait_for_xrandr_monitors 2

# Set a wallpaper on startup (if feh is installed).
if command -v feh >/dev/null 2>&1; then
  feh --no-fehbg --bg-fill --randomize "$HOME"/Pictures/wallpapers/* || true
fi

# Keyboard layout tweaks (safe if not present).
if command -v setxkbmap >/dev/null 2>&1; then
  setxkbmap gb || true
fi
if command -v xmodmap >/dev/null 2>&1; then
  xmodmap -e 'keysym Menu = Super_R' || true
fi


# Night light / colour temperature.
# Use manual location config (deployed by Home Manager).
run_once redshift redshift -c "$HOME/.config/redshift/redshift.conf"

# Ensure session D-Bus is up before starting tray-dependent apps.
wait_for_dbus_session

# Polkit authentication agent is managed by Home Manager as a systemd user service:
# `services.polkit-gnome-authentication-agent-1.enable = true;`
#
# We intentionally do not start it here because PATH during WM startup can be incomplete,
# causing `command -v` checks to fail and silently skipping the agent.

# Core desktop "glue" for MVP (as per plan).
run_once picom picom --config "$HOME/.config/picom/picom.conf"
run_once dunst dunst

# Clipboard history watcher (X11).
run_once cliphist-x11-watch cliphist-x11-watch

# Eww bar (MVP): open bars on both monitors.
# `eww open-many` starts the daemon if needed.
if command -v eww >/dev/null 2>&1; then
  eww open-many bar0 bar1 >/dev/null 2>&1 || true
fi

# Eww's systray acts as a StatusNotifierWatcher on D-Bus.
# If nm-applet starts before the watcher exists, the icon can fail to dock until the bar restarts.
wait_for_dbus_name org.kde.StatusNotifierWatcher

# Provide a system tray so nm-applet/blueman-applet have somewhere to dock.

# nm-applet defaults to legacy GtkStatusIcon on some setups, which Eww's systray can't display.
# `--indicator` forces AppIndicator/StatusNotifierItem so the Wi-Fi/VPN icons show up.
#
# Important: even with the D-Bus wait above, we've seen a race where nm-applet starts
# just before the watcher fully initialises and the icon only appears after restarting Eww.
# Restarting it here makes it reliably register with the watcher.
restart_process nm-applet nm-applet --indicator
run_once blueman-applet blueman-applet

# Volume control icon in tray.
run_once volumeicon volumeicon

# Screenshot tool in tray.
# `--tray` ensures the status icon is created for the systray.
# Use restart_process to reliably re-register with the StatusNotifierWatcher.
restart_process flameshot flameshot --tray

run_once xfce4-volumed-pulse xfce4-volumed-pulse

exit 0
