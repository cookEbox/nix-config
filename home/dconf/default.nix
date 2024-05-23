# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      cursor-theme = "gruvbox-dark-icons-gtk";
      gtk-theme = "gruvbox-dark-gtk";
      icon-theme = "gruvbox-dark-icons-gtk";
    };

    "org/mate/desktop/accessibility/keyboard" = {
      bouncekeys-beep-reject = true;
      bouncekeys-delay = 300;
      bouncekeys-enable = false;
      enable = false;
      feature-state-change-beep = false;
      mousekeys-accel-time = 1200;
      mousekeys-enable = false;
      mousekeys-init-delay = 160;
      mousekeys-max-speed = 750;
      slowkeys-beep-accept = true;
      slowkeys-beep-press = true;
      slowkeys-beep-reject = false;
      slowkeys-delay = 300;
      slowkeys-enable = false;
      stickykeys-enable = false;
      stickykeys-latch-to-lock = true;
      stickykeys-modifier-beep = true;
      stickykeys-two-key-off = true;
      timeout = 120;
      timeout-enable = false;
      togglekeys-enable = false;
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

    "org/mate/desktop/peripherals/mouse" = {
      cursor-theme = "mate-black";
    };

    "org/mate/desktop/session" = {
      auto-save-session = true;
      session-start = 1716485250;
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
      object-id-list = [ "object-9" "object-10" "object-11" "object-12" "object-13" "object-14" "object-15" ];
      toplevel-id-list = [ "toplevel-0" ];
    };

    "org/mate/panel/menubar" = {
      show-desktop = true;
      show-places = false;
    };

    "org/mate/panel/objects/object-10" = {
      applet-iid = "ClockAppletFactory::ClockApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1829;
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
      applet-iid = "GvcAppletFactory::GvcApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1633;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-14" = {
      applet-iid = "NetspeedAppletFactory::NetspeedApplet";
      object-type = "applet";
      panel-right-stick = false;
      position = 1669;
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

    "org/mate/terminal/profiles/default" = {
      background-color = "#FFFFFFFFDDDD";
      bold-color = "#000000000000";
      foreground-color = "#000000000000";
      palette = "#2E2E34343636:#CCCC00000000:#4E4E9A9A0606:#C4C4A0A00000:#34346565A4A4:#757550507B7B:#060698209A9A:#D3D3D7D7CFCF:#555557575353:#EFEF29292929:#8A8AE2E23434:#FCFCE9E94F4F:#72729F9FCFCF:#ADAD7F7FA8A8:#3434E2E2E2E2:#EEEEEEEEECEC";
      visible-name = "Default";
    };

  };
}
