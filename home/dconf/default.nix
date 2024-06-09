# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "default";
      cursor-size = 24;
      cursor-theme = "oomox-gruvbox-dark";
      enable-animations = true;
      font-name = "Noto Sans,  10";
      gtk-theme = "gruvbox-dark";
      icon-theme = "oomox-gruvbox-dark";
      scaling-factor = mkUint32 1;
      text-scaling-factor = 1.0;
      toolbar-style = "text";
      toolkit-accessibility = false;
    };

    "org/gnome/simple-scan" = {
      document-type = "photo";
      paper-height = 0;
      paper-width = 0;
    };

    "org/mate/caja/window-state" = {
      geometry = "800x550+559+264";
      icon-theme = "oomox-gruvbox-dark";
      maximized = false;
      start-with-sidebar = true;
      start-with-status-bar = true;
      start-with-toolbar = true;
    };

    "org/mate/desktop/applications/terminal" = {
      exec = "alacritty";
    };

    "org/mate/desktop/interface" = {
      gtk-decoration-layout = ":minimize,maximize,close";
      gtk-theme = "gruvbox-dark";
      icon-theme = "oomox-gruvbox-dark";
      window-scaling-factor = 0;
    };

    "org/mate/desktop/keybindings/custom0" = {
      action = "whatsapp-for-linux";
      binding = "<Mod4>m";
      name = "WhatsApp for Linux";
    };

    "org/mate/desktop/keybindings/custom2" = {
      action = "rofi -show drun";
      binding = "<Mod4>space";
      name = "Rofi";
    };

    "org/mate/desktop/keybindings/custom3" = {
      action = "firefox";
      binding = "<Mod4>b";
      name = "Browser";
    };

    "org/mate/desktop/keybindings/custom4" = {
      action = "thunderbird";
      binding = "<Mod4>e";
      name = "Thunderbird";
    };

    "org/mate/desktop/peripherals/keyboard" = {
      numlock-state = "on";
    };

    "org/mate/desktop/peripherals/mouse" = {
      cursor-theme = "mate-black";
    };

    "org/mate/desktop/session" = {
      auto-save-session = true;
      session-start = 1717662849;
    };

    "org/mate/desktop/sound" = {
      event-sounds = true;
      theme-name = "__no_sounds";
    };

    "org/mate/marco/general" = {
      action-double-click-titlebar = "toggle_maximize";
      allow-tiling = true;
      button-layout = ":minimize,maximize,close";
      num-workspaces = 6;
      theme = "gruvbox-dark";
    };

    "org/mate/marco/global-keybindings" = {
      run-command-terminal = "<Mod4>Return";
      switch-to-workspace-1 = "<Mod4>1";
      switch-to-workspace-2 = "<Mod4>2";
      switch-to-workspace-3 = "<Mod4>3";
      switch-to-workspace-4 = "<Mod4>4";
      switch-to-workspace-5 = "<Mod4>5";
      switch-to-workspace-6 = "<Mod4>6";
      switch-to-workspace-down = "disabled";
      switch-to-workspace-left = "disabled";
      switch-to-workspace-right = "disabled";
      switch-to-workspace-up = "disabled";
      switch-windows = "<Mod4>Tab";
    };

    "org/mate/marco/window-keybindings" = {
      close = "<Mod4>w";
      maximize = "<Mod4>Up";
      maximize-vertically = "<Mod4>Up";
      minimize = "<Shift><Mod4>Down";
      move-to-workspace-1 = "<Shift><Mod4>exclam";
      move-to-workspace-2 = "<Shift><Mod4>quotedbl";
      move-to-workspace-3 = "<Shift><Mod4>sterling";
      move-to-workspace-4 = "<Shift><Mod4>dollar";
      move-to-workspace-5 = "<Shift><Mod4>percent";
      move-to-workspace-6 = "<Shift><Mod4>asciicircum";
      move-to-workspace-down = "disabled";
      move-to-workspace-left = "disabled";
      move-to-workspace-right = "disabled";
      move-to-workspace-up = "disabled";
      tile-to-side-e = "<Mod4>Right";
      tile-to-side-w = "<Mod4>Left";
      toggle-maximized = "<Mod4>Up";
      unmaximize = "<Mod4>Down";
    };

    "org/mate/marco/workspace-names" = {
      name-1 = "home";
      name-2 = "www";
      name-3 = "dev";
      name-4 = "admin";
      name-5 = "vm";
      name-6 = "misc";
      name-7 = "vm";
    };


    "org/mate/power-manager" = {
      button-lid-ac = "suspend";
      button-lid-battery = "suspend";
      button-power = "interactive";
      button-suspend = "suspend";
    };

    "org/mate/search-tool" = {
      default-window-height = 398;
      default-window-maximized = false;
      default-window-width = 554;
      look-in-folder = "/home/nick";
    };

    "org/mate/search-tool/select" = {
      contains-the-text = true;
    };

    "org/mate/settings-daemon/plugins/media-keys" = {
      email = "<Mod4>e";
      home = "<Mod4>f";
      power = "<Mod4>q";
      search = "disabled";
      www = "disabled";
    };

    "org/mate/terminal/profiles/default" = {
      background-color = "#FFFFFFFFDDDD";
      bold-color = "#000000000000";
      foreground-color = "#000000000000";
      palette = "#2E2E34343636:#CCCC00000000:#4E4E9A9A0606:#C4C4A0A00000:#34346565A4A4:#757550507B7B:#060698209A9A:#D3D3D7D7CFCF:#555557575353:#EFEF29292929:#8A8AE2E23434:#FCFCE9E94F4F:#72729F9FCFCF:#ADAD7F7FA8A8:#3434E2E2E2E2:#EEEEEEEEECEC";
      visible-name = "Default";
    };

    "org/virt-manager/virt-manager" = {
      manager-window-height = 550;
      manager-window-width = 550;
      xmleditor-enabled = true;
    };

    "org/virt-manager/virt-manager/confirm" = {
      delete-storage = false;
      forcepoweroff = false;
      removedev = true;
      unapplied-dev = true;
    };

    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };

    "org/x/warpinator/preferences" = {
      ask-for-send-permission = true;
      autostart = false;
      connect-id = "NIXLAP-C162C9E875A95F9F7B09";
      no-overwrite = true;
    };

  };
}
