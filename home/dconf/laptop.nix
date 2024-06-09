# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
    "org/mate/panel/general" = {
      default-layout = "default";
      object-id-list = [ "object-9" "object-10" "object-11" "object-12" "object-15" "object-13" ];
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
      position = 1744;
      toplevel-id = "toplevel-0";
    };

    "org/mate/panel/objects/object-10/prefs" = {
      custom-format = "";
      format = "24-hour";
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
}
