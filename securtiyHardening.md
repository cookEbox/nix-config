# Desktop Security Hardening Plan (NixOS)

This document consolidates **concrete, minimal security improvements** for your NixOS desktop, based on a review of your current flake and host configuration. The goal is to **reduce real attack surface** (browser, credentials, local escalation) without introducing security theater or workflow breakage.

---

## 1. Threat Model (Explicit)

**Assumptions (inferred from config):**

* Single-user technical desktop
* No intentional public services exposed
* Heavy browser + Electron usage
* Nix-based supply chain (low risk)

**Primary risks:**

1. Browser / Electron compromise
2. Credential leakage
3. Local privilege escalation
4. User-assisted execution

**Out of scope:**

* Targeted nation-state attacks
* Malicious kernel modules

---

## 2. Mandatory Fixes (High Severity)

### 2.1 Remove Plaintext Password From Flake

**Problem:** `initialPassword` is stored in the Nix store and git history.

**Fix (recommended):**
Remove the password entirely and set it interactively once.

```nix
users.users.nick = {
  isNormalUser = true;
  shell = pkgs.zsh;
  extraGroups = [ "wheel" "libvirtd" "lp" "scanner" "plugdev" ];
  # DO NOT set initialPassword in Nix
};
```

Or, if you must:

```nix
users.users.nick.initialHashedPassword = "<hashed>";
```

---

### 2.2 Harden or Disable SSH on Desktop

If SSH is **not required**:

```nix
services.openssh.enable = false;
```

If SSH **is required**:

```nix
services.openssh = {
  enable = true;
  settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
    AllowUsers = [ "nick" ];
  };
};
```

---

## 3. Strongly Recommended Hardening (Low Friction)

### 3.1 Kernel & Sysctl Hardening

Blocks common local escalation and info-leak primitives.

```nix
security = {
  protectKernelImage = true;
  sudo.execWheelOnly = true;
  sudo.wheelNeedsPassword = true;
};

boot.kernel.sysctl = {
  "kernel.kptr_restrict" = 2;
  "kernel.dmesg_restrict" = 1;
  "fs.protected_symlinks" = 1;
  "fs.protected_hardlinks" = 1;
};
```

---

### 3.2 Enable AppArmor (Safe Default)

```nix
security.apparmor.enable = true;
```

No custom profiles required; NixOS defaults are sufficient.

---

## 4. Browser & Electron Containment (High ROI)

### 4.1 Enable Flatpak

```nix
services.flatpak.enable = true;
```

### 4.2 Move High-Risk Apps to Flatpak

Strongly recommended:

* Firefox
* Discord
* Zoom
* Teams
* WhatsApp

Benefits:

* Filesystem isolation
* Camera/mic permission gating
* Reduced impact of browser exploits

---

## 5. Firewall Status (Already Good)

Your current firewall configuration is **correct and appropriate**:

* Default deny inbound
* No accidental open ports
* VPN interfaces explicitly trusted

**No changes required.**

---

## 6. USB Permissions (Conscious Tradeoff)

You currently allow broad access via `MODE="0666"` for certain USB devices.

**This is acceptable if intentional**, but be aware:

* USB is a real attack vector (BadUSB class)
* Any local process can access these devices

Optional improvement:

* Narrow to group-based access instead of world-writable

---

## 7. Antivirus & Scanning (Minimal, Correct Use)

### 7.1 Do NOT Use Resident Antivirus

Reasons:

* Minimal benefit on Linux desktop
* Adds kernel attack surface
* Mostly security theater

### 7.2 Use On-Demand Scanning Only

```nix
environment.systemPackages = with pkgs; [
  clamav
  rkhunter
];
```

Use cases:

* After suspicious downloads
* After browser incidents
* After mounting foreign filesystems

---

## 8. ProtonVPN debug playbook (after NixOS upgrade)

Use this when ProtonVPN stops working after a NixOS upgrade (e.g. 25.11).

### 8.1 Identify how you connect

- **NetworkManager connection** (GUI / nmcli): preferred for desktop use.
- **protonvpn-cli** (if used): note whether it uses OpenVPN or WireGuard.

Write down which one you use before changing anything.

### 8.2 Quick sanity checks

1. Confirm networking is otherwise OK:
   - Can you browse without VPN?
2. Confirm the VPN interface appears when you try to connect:
   - `ip a`
   - `ip r`
3. Confirm DNS behaviour:
   - `resolvectl status` (if using systemd-resolved)
   - `cat /etc/resolv.conf` (if not)

### 8.3 NetworkManager logs (most useful)

Capture logs from the current boot:

- `journalctl -u NetworkManager -b --no-pager`

If you want to focus on VPN-related lines:

- `journalctl -u NetworkManager -b --no-pager | rg -i "vpn|openvpn|wireguard|wg|proton"`

### 8.4 Inspect the connection profile

List connections:

- `nmcli connection show`

Show the VPN connection details:

- `nmcli connection show "<vpn-name>"`

Try bringing it up and capture the error:

- `nmcli connection up "<vpn-name>" --ask`

### 8.5 Common upgrade regressions to check

1. **Missing NetworkManager VPN plugins**
   - OpenVPN: ensure the OpenVPN plugin is installed/enabled.
   - WireGuard: ensure WireGuard tooling is present.

2. **Secrets/keyring agent not running**
   - Symptoms: repeated password prompts, auth failures, or silent connect failures.
   - Fix: ensure a secrets agent is running (e.g. gnome-keyring) and that NM can access it.

3. **OpenVPN option deprecations / cipher changes**
   - Symptoms: OpenVPN connects then immediately drops; logs mention cipher/auth options.
   - Fix: update the OpenVPN config/profile to match current OpenVPN defaults.

4. **DNS handling changes**
   - Symptoms: VPN connects but name resolution fails.
   - Fix: check whether systemd-resolved is enabled and whether NM is configured to manage DNS.

5. **Firewall / interface trust changes**
   - Symptoms: tunnel comes up but traffic is blocked.
   - Fix: confirm firewall rules and whether the VPN interface is trusted as expected.

### 8.6 Minimal data to capture for future debugging

When it fails, save:
- Output of `nmcli connection show` (redact sensitive names if needed)
- Output of `nmcli connection up "<vpn-name>" --ask`
- `journalctl -u NetworkManager -b --no-pager` (or at least the VPN-related lines)
- `ip a` and `ip r`

---

## 8. Final Checklist

### Mandatory

* [ ] Remove `initialPassword` from flake
* [ ] Disable or harden SSH

### Strongly Recommended

* [ ] Enable AppArmor
* [ ] Apply kernel sysctl hardening
* [ ] Use Flatpak for browsers/Electron apps

### Optional / Power User

* [ ] Review USB `0666` rules
* [ ] Firejail for non-Flatpak apps
* [ ] Periodic on-demand scans

---

## 9. Bottom Line

You were **right** not to run antivirus by default.
Your system is already **well above average** security-wise.

The real gains come from:

* Credential hygiene
* Browser containment
* Eliminating quiet footguns

Nothing here meaningfully harms your workflow.

