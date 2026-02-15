{ pkgs, ... }:

{
  services.xserver.windowManager.xmonad = {
    enable = true;
    enableContribAndExtras = true;

    # Ensure the XMonad session uses the Home Manager managed config.
    # Some setups default to the compiled-in config unless this is set.
    # Important: this uses the config from the flake at build time.
    # After switching, use Mod+q (xmonad --recompile; xmonad --restart) to apply changes.
    config = pkgs.writeText "xmonad.hs" (builtins.readFile ../home/xmonad/xmonad.hs);
  };
}

