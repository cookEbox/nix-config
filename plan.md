# System Setup Plan (Prioritised)

## 1. Unify tmux Setup (Mac + nixBox)

**Goal**: Eliminate divergence between environments and resolve navigation/button warnings by converging on a single tmux configuration.

### Tasks

* [ ] Compare existing Home Manager tmux modules: `home/tmux/darwin.nix` (Mac, known-good) vs `home/tmux/default.nix` (nixBox)
* [ ] Promote the Mac config as the canonical baseline and apply it to nixBox
  * Option A (preferred): extract shared parts into `home/tmux/common.nix` and have both OS modules import it
  * Option B: make `home/tmux/default.nix` match the Mac config and delete/retire `home/tmux/darwin.nix`
* [ ] Keep only truly OS-specific deltas behind conditionals (only if required)
* [ ] Identify root cause of navigation warning
  * likely: tmux bindings to `TmuxNavigate*` commands not being defined/loaded (plugin/version mismatch)
  * or: terminal Meta/Option key encoding differences (ESC-prefix vs real Meta)
  * or: terminfo mismatch (`tmux-256color` not installed)
* [ ] Validate on both systems: pane navigation (C-h/j/k/l), window navigation (M-j/M-k), popups, copy-mode bindings

### Notes / Hypotheses

* Likely issue: plugin-provided `TmuxNavigate*` commands vs tmux/plugin version mismatch (causes warnings/unknown command)
* Also possible: Meta/Option handling differs between terminals (Kitty/Alacritty/Terminal.app)
* Less likely (but easy to check): `$TERM`/terminfo mismatch (`tmux-256color`, `xterm-256color`, `screen-256color`)

### Success Criteria

* No warnings on either system
* Identical navigation behaviour

---

## 2. Add GitHub Copilot to Neovim

**Goal**: Enable AI-assisted development in Neovim using work-provided token.

### Tasks

* [ ] Choose integration approach:

  * Option A: `github/copilot.vim`
  * Option B: `copilot.lua` (preferred for Lua-based config)
* [ ] Add plugin via Nix-managed Neovim config
* [ ] Authenticate using work token
* [ ] Configure keybindings (accept, next, previous suggestions)
* [ ] Ensure no conflict with existing Avante / LSP setup

### Notes / Constraints

* Must work in restricted work environment
* Avoid plugins requiring external Node installs unless managed via Nix

### Success Criteria

* Inline suggestions appear in insert mode
* Accept/reject bindings work reliably

---

## 3. Screen Flickering Investigation (nixBox)

**Goal**: Identify and eliminate flickering at top of screen.

### Tasks

* [ ] Reproduce flicker consistently
* [ ] Disable EWW → test
* [ ] Disable XMonad → test (use fallback WM)
* [ ] Test compositor state (picom / none)
* [ ] Check GPU driver (modesetting vs vendor)
* [ ] Inspect logs (`journalctl`, Xorg logs)

### Hypotheses

* EWW redraw loop or incorrect window struts
* XMonad layout or fullscreen handling
* Compositor vsync / tearing issue

### Success Criteria

* Flicker eliminated or root cause isolated

---

## 4. XMonad Input Freeze Issue

**Symptom**: XMonad keybindings work, but applications do not receive keyboard/mouse input until restart.

### Tasks

* [ ] Check if issue correlates with focus handling
* [ ] Inspect `manageHook` and `handleEventHook`
* [ ] Verify no stuck modifier keys (esp. Super/Alt)
* [ ] Test with minimal XMonad config
* [ ] Check X input devices (`xinput list`, `xinput test`)
* [ ] Review logs during failure

### Hypotheses

* Focus lock / broken input grab
* XMonad event hook misconfiguration
* External tool (EWW, panel, or compositor) stealing input

### Success Criteria

* Root cause identified
* No need to restart XMonad to regain input

---

# Cross-Cutting Improvements

* [ ] Centralise configs via Nix where possible
* [ ] Reduce divergence between Mac and nixBox environments
* [ ] Document reproducible debugging steps for WM issues

---

# Next Actions (Immediate)

1. Diff tmux configs (Mac vs nixBox)
2. Reproduce flicker and test with EWW disabled
3. Install Copilot plugin in Neovim (minimal config first)
4. Capture state when XMonad input bug occurs (logs + xinput)
