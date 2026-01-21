# hosts/linode/infra/forgejo/deploy-forgejo.nix
{ pkgs, ... }:
let
  script = pkgs.writeShellScript "deploy-forgejo" ''
    set -euo pipefail

    echo "Deploy Forgejo (TODO)"
    echo "This script should:"
    echo "  - install/configure forgejo service (systemd) on Ubuntu"
    echo "  - set SSH on port 2222"
    echo "  - configure data dir, sqlite, user, permissions"
    echo "  - restart services"
    exit 1
  '';
in
{
  app = {
    type = "app";
    program = "${script}";
  };

  forgejo = pkgs.writeShellApplication {
    name = "deploy-forgejo";
    text = builtins.readFile script;
  };
}

