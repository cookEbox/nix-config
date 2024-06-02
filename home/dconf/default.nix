# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "default";
      cursor-theme = "oomox-gruvbox-dark";
      gtk-theme = "gruvbox-dark";
      icon-theme = "oomox-gruvbox-dark";
      toolkit-accessibility = false;
    };

    "org/gnome/nm-applet/eap/3fcdd7f9-274d-4b8b-af23-3f8b86c41f39" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/simple-scan" = {
      document-type = "photo";
      paper-height = 0;
      paper-width = 0;
    };

    "org/mate/caja/window-state" = {
      geometry = "800x550+559+264";
      maximized = false;
      start-with-sidebar = true;
      start-with-status-bar = true;
      start-with-toolbar = true;
    };

    "org/mate/desktop/applications/terminal" = {
      exec = "alacritty";
    };

    "org/mate/desktop/background" = {
      color-shading-type = "vertical-gradient";
      picture-filename = "/nix/store/v48ywzz713gnh9ggas4hv3xafc1r7045-mate-screensaver-1.26.2/share/backgrounds/cosmos/background-1.xml";
      picture-options = "zoom";
      primary-color = "rgb(88,145,188)";
      secondary-color = "rgb(60,143,37)";
      show-desktop-icons = false;
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

    "org/mate/desktop/keybindings/custom1" = {
      action = "/nix/store/l9c6lb4566p732rd8csy4v7cwyl0s62f-caja-1.26.3/bin/caja-autorun-software";
      binding = "<Alt>Tab";
      name = "Autorun Prompt";
    };

    "org/mate/desktop/keybindings/custom2" = {
      action = "rofi -show run";
      binding = "<Mod4>space";
      name = "Rofi";
    };

    "org/mate/desktop/keybindings/custom3" = {
      action = "firefox";
      binding = "<Mod4>b";
      name = "Browser";
    };

    "org/mate/desktop/peripherals/keyboard" = {
      numlock-state = "on";
    };

    "org/mate/desktop/peripherals/mouse" = {
      cursor-theme = "mate-black";
    };

    "org/mate/desktop/session" = {
      auto-save-session = true;
      session-start = 1717369584;
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
      move-to-workspace-6 = "<Shift><Mod4>percent";
      move-to-workspace-down = "disabled";
      move-to-workspace-left = "disabled";
      move-to-workspace-right = "disabled";
      move-to-workspace-up = "disabled";
      tile-to-side-e = "<Mod4>Right";
      tile-to-side-w = "<Mod4>Left";
      toggle-maximized = "<Mod4>Up";
      unmaximize = "<Shift><Mod4>Up";
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

    "org/mate/panel/general" = {
      default-layout = "default";
      object-id-list = [ "object-9" "object-10" "object-11" "object-12" "object-15" "object-13" ];
      toplevel-id-list = [ "toplevel-0" ];
    };

    "org/mate/panel/menubar" = {
      show-desktop = true;
      show-places = false;
    };

    "org/mate/panel/objects/object-0" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1479;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-1" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1595;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-10" = {
      applet-iid = "ClockAppletFactory::ClockApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1744;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-10/prefs" = {
      custom-format = "";
      format = "24-hour";
    };

    "org/mate/panel/objects/object-11" = {
      object-type = "separator";
      panel-right-stick = false;
      position = 1230;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-12" = {
      applet-iid = "WnckletFactory::WorkspaceSwitcherApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 202;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-12/prefs" = {
      display-workspace-names = true;
      wrap-workspaces = false;
    };

    "org/mate/panel/objects/object-13" = {
      applet-iid = "NotificationAreaAppletFactory::NotificationArea";
      object-type = "applet";
      panel-right-stick = false;
      position = 1709;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-15" = {
      applet-iid = "MateWeatherAppletFactory::MateWeatherApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1973;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-15/prefs" = {
      coordinates = "52-27-00N 001-43-59W";
      distance-unit = "km";
      location1 = "EGBB";
      location2 = ":wm";
      location3 = "---";
      location4 = "Birmingham";
      speed-unit = "km/h";
      temperature-unit = "Centigrade";
    };

    "org/mate/panel/objects/object-16" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = true;
      position = 59;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-17" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1659;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-18" = {
      applet-iid = "NetspeedAppletFactory::NetspeedApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1453;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-19" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1471;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-2" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1595;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-20" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1496;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-21" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1496;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-22" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1485;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-23" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1485;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-24" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1411;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-25" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1411;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-28" = {
      applet-iid = "NotificationAreaAppletFactory::NotificationArea";
      object-type = "applet";
      panel-right-stick = false;
      position = 1540;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-3" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = true;
      position = 60;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-4" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = true;
      position = 61;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-5" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1447;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-6" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = true;
      position = 55;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-7" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = true;
      position = 56;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-8" = {
      applet-iid = "BattstatAppletFactory::BattstatApplet";
      object-type = "applet";
      panel-right-stick = true;
      position = 57;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-9" = {
      object-type = "menu-bar";
      panel-right-stick = false;
      position = 0;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/toplevels/toplevel-0" = {
      monitor = 0;
      orientation = "top";
      screen = 0;
      y = 0;
      y-bottom = -1;
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

    "org/x/warpinator/preferences" = {
      ask-for-send-permission = true;
      autostart = false;
      connect-id = "NIXLAP-C162C9E875A95F9F7B09";
      no-overwrite = true;
    };

  };
}
