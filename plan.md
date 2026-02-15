# Project plan: Nix/Home Manager + macOS tmux/direnv + HM-first direction

## Project goal
1. Fix macOS Home Manager regression: enabling `direnv` causes tmux UX regressions:
   - `<C-s> <S-s>` session switch popup flashes and closes immediately
   - tmux split navigation via `<C-j/k/l/;>` is broken
2. Move towards a **Home Manager-first** setup (portable across NixOS + macOS + future Fedora base), without committing to leaving NixOS yet.
3. Prepare an option to run **Fedora as gaming base** while keeping dev environment in Nix/Home Manager.

## Constraints
- Prefer staged refinement; don’t over-plan.
- Minimal, reversible changes.
- Keep existing repo conventions (flake, `hosts/*`, `home/*` modules).
- Tooling: Nix flakes, Home Manager, tmux, zsh, direnv/nix-direnv.
- macOS terminal: **Kitty** (Alacritty not used on mac).

## Current state (relevant)
- mac config: `hosts/workMac/home/default.nix` enables:
  - `programs.direnv.enable = true;`
  - `programs.direnv.nix-direnv.enable = true;`
- tmux config: `home/tmux/default.nix` defines popup session switcher:
  - `bind-key S display-popup -E 'tmux switch-client -t "$(tmux ls | fzf ...)"'`
- zsh is managed via HM (`home/zsh/default.nix`).
- Kitty on mac launches tmux as the shell (`home/macKitty/default.nix`).

## Definition of “done”
### Mac fix (completed)
- ✅ With `direnv` enabled, tmux:
  - ✅ shows the session switch popup reliably (no flash-close)
  - ✅ split navigation keys work as before
- ✅ No new prompts or broken shell startup behaviour.

### HM-first direction
- Clear module structure where:
  - “base dev environment” is shared across OSes
  - OS-specific bits are isolated
  - adding a new host (e.g. Fedora) is mostly wiring + username/homeDirectory

## Assumptions
- The popup flash-close is caused by the popup command’s shell environment exiting early or failing when `direnv` hooks are active.
- Split navigation breakage is likely due to keybinding/command execution context changes triggered by direnv integration (not tmux itself).
- Disabling `direnv` will likely restore behaviour (to be confirmed).

## Unknowns / risks (flagged early)
- Exact failure mode is not yet captured (no error output yet).
- Fedora “rollbacks” require choosing a concrete mechanism (Btrfs snapshots tooling vs rpm-ostree variants).

## Critical path (explicit)
### Mac tmux/direnv regression (completed)
1. ✅ **Confirm causality**: verify that disabling `direnv` restores tmux popup + split navigation.
2. ✅ **Identify failure mode**: determine whether the popup command is failing (shell exits) vs keybindings not firing.
3. ✅ **Apply minimal mitigation**: adjust tmux popup commands and/or shell integration so `direnv` doesn’t interfere.
4. ✅ **Regression-proof**: add a small checklist/test procedure so future HM changes don’t re-break tmux.

## Plan (staged)

### Stage 1 — Reproduce + isolate (mac tmux/direnv) (completed)
**Objective:** prove the break is due to direnv and capture the exact failure mode.

**Tasks**
1. ✅ Confirm baseline:
   - Temporarily disable `programs.direnv` in `hosts/workMac/home/default.nix` and re-apply HM.
   - Verify:
     - `<C-s> <S-s>` popup stays open and works
     - tmux split navigation keys work
2. ✅ Confirm regression:
   - Re-enable `direnv` and re-apply HM.
   - Verify the break returns.
3. ✅ Capture diagnostics:
   - In a tmux pane, run:
     - `tmux show -g | rg -n "default-shell|default-command|update-environment|terminal|escape-time"`
     - `echo $SHELL`
   - Try running the popup pipeline manually in a tmux pane (copy the command from tmux config) and capture any error output.

**Exit criteria:** we can say “direnv causes X” with evidence (error output or behavioural difference).

---

### Stage 2 — Fix strategy selection (choose smallest effective change) (completed)
**Objective:** pick the least invasive fix that restores tmux behaviour while keeping direnv.

**Candidate fixes (ranked by likely minimal impact)**
1. ✅ **Run popup commands in a login shell** (stabilises env + avoids early exit)
   - Wrap popup command with `zsh -lic '...'`.
2. ⏭️ **Adjust tmux environment propagation**
   - Review `update-environment` and ensure `DIRENV_*` variables aren’t causing tmux to refresh/override state unexpectedly.
3. ⏭️ **Adjust direnv hook placement**
   - Ensure direnv is only hooked in interactive shells where it’s safe.
4. ⏭️ **Keybinding conflict resolution**
   - Confirm whether Kitty/macOS shortcuts or zsh bindings are intercepting the keys when direnv is enabled.

**Exit criteria:** chosen fix is clear, minimal, and testable.

---

### Stage 3 — Implement + verify (mac fix) (completed)
**Objective:** implement the chosen fix and confirm “done”.

**Tasks**
1. ✅ Apply the minimal change (likely in `home/tmux/default.nix`, possibly `home/zsh/default.nix`).
2. ✅ Re-apply HM on mac.
3. ✅ Verify:
   - popup works repeatedly
   - split navigation works
   - direnv still loads `.envrc` correctly
4. ✅ Add a short note in this plan (or a small checklist section) describing the regression test.

**Exit criteria:** mac “done” definition met.

---

### Stage 4 — HM-first refactor (no OS switch yet)
**Objective:** make HM configs more portable and reduce duplication.

**Additions (from recent macOS + AWS/RHEL learnings)**
- **Modularise zsh like tmux** so host/OS-specific aliases don’t leak into other machines.
  - Keep a shared zsh base (prompt, completion, common aliases).
  - Split host/OS-specific aliases into separate modules (e.g. NixOS-only rebuild aliases vs mac-only helpers).
- **Keep non-NixOS (AWS/RHEL) targets minimal at first**:
  - Avoid any `.bashrc` hacks like `exec zsh` (can break non-interactive shells/automation).
  - Prefer enabling zsh via `chsh` (interactive login shells) or explicit terminal config.
  - Ensure NixOS-only commands (`nixos-rebuild`, etc.) are gated or isolated.

---

### Stage 4.5 — Security hardening (post-upgrade, NixOS 25.11)
**Objective:** apply minimal, high-ROI desktop hardening now that the system is on NixOS 25.11, without destabilising daily workflows.

**Status:**
- ✅ NixOS is on **25.11**
- ✅ VPN is working
- ✅ Neovim is working

**Reference:** `securtiyHardening.md`

**Tasks (prioritised)**
1. Mandatory hygiene (low risk, high ROI):
   - Ensure no plaintext passwords exist in the repo (e.g. `initialPassword`).
   - Review secrets handling (prefer agenix/sops-nix or external secret storage).
   - Disable SSH if not needed; otherwise harden it (keys-only, no password auth, restrict users).
2. Kernel / MAC hardening (incremental):
   - Enable AppArmor (and confirm it doesn’t break core apps).
   - Apply a minimal sysctl hardening set (avoid aggressive networking tweaks unless needed).
3. App isolation (optional, workflow-dependent):
   - Consider Flatpak for high-risk desktop apps (browser/Electron) if it fits the workflow.

**Regression checklist (run after each hardening change)**
- Boot + login works
- NetworkManager works
- ✅ VPN connects successfully
- ✅ Neovim launches and LSP works

**Exit criteria:** hardening items above are applied (or explicitly deferred), and the regression checklist passes.

**Tasks**
1. Define module layers (keep it simple):
   - `home/base.nix` (shell, editor, git, core CLI)
   - `home/linux-gui.nix` (rofi, gtk, etc.)
   - `home/mac-gui.nix` (kitty, aerospace)
2. Remove duplication:
   - Decide whether `direnv` is managed via `programs.direnv` only (recommended) and avoid also listing it in `home.packages`.
3. Split tmux config by platform (needed):
   - Keep a shared tmux base module (common options, plugins, session scripts).
   - Add OS-specific tmux modules for keybindings/terminal quirks:
     - `home/tmux/linux.nix`
     - `home/tmux/darwin.nix`
   - Wire them from host modules (Linux hosts import linux tmux module; mac hosts import darwin tmux module).
4. Split zsh config by platform/host (needed):
   - Keep a shared zsh base module (completion, history, common aliases/functions).
   - Add OS/host-specific zsh modules for machine-specific aliases:
     - `home/zsh/nixos.nix` (nixos-rebuild aliases, system maintenance)
     - `home/zsh/darwin.nix` (mac-only helpers)
     - `home/zsh/remote.nix` (safe remote helpers; no NixOS-only commands)
   - Ensure `homeConfigurations.work` (AWS/RHEL) imports only the safe zsh module(s).
5. Make host configs thin:
   - `hosts/workMac/home/default.nix` should mostly be identity + imports + a few host-specific toggles.
   - `hosts/work/home/default.nix` should stay minimal initially (avoid risky shell glue; add features incrementally).

**Exit criteria:** adding a new host is straightforward and doesn’t require copying large blocks.

---

### Stage 5 — Gaming base migration (staged)
**Objective:** keep the same end state (Bazzite as the gaming-focused base OS + portable dev environment via Nix/Home Manager), but add a safer middle step:
1) first reach the target desktop/workflow on a normal NixOS install
2) once it’s stable, swap the base OS to Bazzite with minimal changes to the user environment

**Candidate base OS (preferred)**
- **Bazzite** (Fedora-based, rpm-ostree/immutable, Steam-focused)
  - Rationale: gaming stack is the product; transactional updates + rollbacks; good fit for “stable base OS + portable dev env”.

**Target desktop/workflow (X11, XMonad-first)**
- Display manager: **SDDM** (system)
- Session: **X11 + XMonad** (system provides session entry; HM provides config)
- Bar/widgets: **Eww** (top bar, translucent, “module pills”, includes tray + stats)
- Compositor: **picom**
- Launcher: **rofi**
- Notifications: **dunst**
- Clipboard: **cliphist + rofi** integration
- Screenshots: **maim + slop** (drag-to-select region) + clipboard + dunst notification
- File manager: **Nemo** (GTK, themes well)
- Auth prompts: **polkit agent** (e.g. polkit-gnome)
- Network/Bluetooth: **nm-applet + blueman-applet** (tray)
- Password manager: **Bitwarden** (desktop + browser extension)
- Mail + calendar (integrated, non-browser): **Evolution**
  - Accounts: Gmail + Outlook.com
  - Notes: prefer OAuth where possible; store credentials in a keyring.
- Browsers:
  - **Chrome** for video/DRM
  - **qutebrowser** for general browsing with a dark user stylesheet
- Terminal: **WezTerm** (GPU, ligatures, icons) (fallback: Kitty)

**DE glue / modcons (XMonad-friendly)**
- Keyring: **gnome-keyring** (credentials for Evolution, browsers, etc.)
- Polkit agent: **polkit-gnome** (GUI auth prompts outside a full DE)
- Notifications: **dunst** (ensure it is started in session)
- Network tray: **nm-applet** (NetworkManager UI)
- Bluetooth tray: **blueman-applet**
- Audio:
  - Backend: PipeWire (system)
  - UI: **pavucontrol**
  - CLI for keybindings: **wpctl** (WirePlumber) or **pamixer**
  - Optional tray: **pasystray** (if you want a clickable tray icon)
- Clipboard:
  - Storage: **cliphist**
  - Menu: rofi-based picker (clipboard history + delete entry)
- Screenshots:
  - Tools: **maim + slop** (drag-to-select region)
  - Scripted workflow: save to `~/Pictures/Screenshots`, copy to clipboard, notify via dunst
- Screen lock + idle:
  - **MVP:** skip lockscreen/idle locking initially to reduce moving parts.
  - When adding later: use **xss-lock** to trigger lock on idle.
  - Preferred locker for styling: **betterlockscreen** (fallback: i3lock).
- Media keys (recommended): **playerctl** for media control
- XDG portals (optional): install/configure if needed for screen sharing or file pickers in sandboxed apps

**Theme + UX consistency (don’t miss these)**
- Choose a single palette (target: **Gruvbox Material**) and apply across:
  - Eww CSS (bar background + module “pills”)
  - rofi theme
  - dunst theme
  - terminal theme (WezTerm/Kitty)
- Fonts:
  - Install a Nerd Font (icons/glyphs) and set it consistently for: terminal, rofi, eww, dunst
- GTK theming (for Nemo/Evolution and dialogs):
  - GTK theme + icon theme + cursor theme
  - Ensure `gtk-application-prefer-dark-theme` is set if desired
- picom:
  - Configure opacity rules for bar/notifications
  - Shadows/rounding to match the “modern” look

**Session startup (XMonad session responsibilities)**
- Start these on login (via HM-managed X session startup or user services):
  - `picom`
  - (Stage 5.2) `eww daemon` + `eww open bar`
  - `dunst`
  - `nm-applet`, `blueman-applet` (and `pasystray` if used)
  - `polkit-gnome-authentication-agent-1`
  - `gnome-keyring-daemon` (if not auto-started)
  - `xss-lock` (wired to your chosen locker)

**Eww bar modules (Stage 5.2 — deferred until after MVP)**
- Workspaces (clickable): integrate with XMonad workspace state + switching
- System tray area (for applets)
- Clock/date
- CPU + RAM usage
- Network status
- Audio volume
- Battery (optional; useful if you ever run this on a laptop)

**Tasks (split into three sub-stages)**

#### Stage 5.1 — XMonad MVP on NixOS (no Eww)
**Goal:** daily-drive XMonad on a standard NixOS install with minimal, reliable “desktop glue”, *without* depending on Eww yet. This should become the baseline we later reuse on Bazzite.

1. Decide rollback mechanism (NixOS-native):
   - Use NixOS generations + boot menu as the primary rollback.
2. Create a dedicated NixOS host/target (if needed):
   - Add a host entry for the gaming machine (or a VM) that represents the target desktop.
   - Keep system config minimal: X11 session plumbing + drivers + SDDM + XMonad session.
   - Recommended safety: keep MATE available as a fallback session until the MVP is stable.
3. Implement the **MVP** desktop stack in Home Manager (portable part):
   - XMonad config + keybindings (terminal, launcher, basic window navigation).
   - Terminal (WezTerm/Kitty) + launcher (`rofi`).
   - Notifications (`dunst`).
   - Polkit agent autostart (e.g. `polkit-gnome-authentication-agent-1`).
   - Tray provider (temporary) + networking UI:
     - `trayer`/`stalonetray` (minimal) or `tint2` (simple panel)
     - `nm-applet` (+ `blueman-applet` if needed)
   - File manager: Nemo.
   - Audio utilities: `pavucontrol` + `wpctl`/`pamixer` for bindings.
   - Optional (early): `picom` for tear-free + basic compositing.
   - Screenshots (simple first): `flameshot` (switch to `maim + slop` scripted flow later if desired).
4. Validate “daily driver” behaviour:
   - Login/session start is reliable
   - Terminal + rofi works
   - Notifications work
   - Polkit prompts work
   - Network/Bluetooth UI works (tray visible)
   - Audio controls work
   - File manager works
   - Gaming basics (Steam, controller, GPU drivers)

**Exit criteria (5.1):** XMonad is usable as a daily driver on NixOS without Eww; any remaining gaps are clearly identified.

#### Stage 5.2 — UX upgrades (Eww last)
**Goal:** once the XMonad MVP is stable, layer on UX improvements (bar/widgets, theming, and “nice workflows”) without destabilising the core session.

1. Add Eww bar:
   - Workspaces (clickable), tray area, clock/date.
   - CPU/RAM, network status, audio volume, battery (if needed).
2. Clipboard workflow:
   - `cliphist` + rofi picker (add/delete entries).
3. Screenshots (scripted workflow):
   - `maim + slop` (drag-to-select), save + copy-to-clipboard + notify.
4. Theme unification:
   - Apply one palette (e.g. Gruvbox Material) across rofi/dunst/terminal/Eww.

**Exit criteria (5.2):** Eww replaces the temporary tray/panel, and UX improvements don’t regress core session stability.

#### Stage 5.3 — Swap base OS to Bazzite (keep HM the same)
**Goal:** replace the base OS with Bazzite while keeping the user environment as unchanged as possible.

1. Decide rollback mechanism (immutable-first):
   - Prefer **rpm-ostree** transactional updates + rollbacks (Bazzite / Silverblue / Kinoite).
2. Define a new HM target for the Bazzite desktop:
   - `homeConfigurations.bazzite` (name TBD)
   - Keep it HM-first: most packages + all configs in HM.
3. Document bootstrap steps (Bazzite / rpm-ostree):
   - Install Bazzite.
   - Layer only what must be system-level (via rpm-ostree):
     - SDDM + X11 session support
     - XMonad (and any required X session files)
   - Install Nix (choose single-user vs multi-user; keep it minimal).
   - Enable flakes.
   - Apply Home Manager.
4. Re-run the validation checklist from Stage 5.1 (and Stage 5.2 if completed).

**Exit criteria (5.3):** you can set up a Bazzite machine and restore your full desktop workflow + dev environment with one HM apply, while gaming remains native and stable.

## What changed vs before
- Added a single critical path: confirm direnv causality → identify failure mode → minimal fix → verify.
- Separated mac fix from HM-first refactor and Fedora exploration.
- Explicitly noted Kitty is the mac terminal and tmux splits are the broken navigation target.

## Prioritized next actions
1. ✅ Mac: tmux/direnv regression fixed (keep a quick regression check when changing HM/tmux/direnv)
2. Start HM-first refactor by extracting `home/base.nix` and slimming host modules
3. Decide module layering + naming (base vs OS-specific)
4. Only then: decide whether to prototype a Fedora HM target

