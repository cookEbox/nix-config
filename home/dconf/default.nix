# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/mate/desktop/applications/terminal" = {
      exec = "alacritty";
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
      session-start = 1716461663;
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
  };
}
