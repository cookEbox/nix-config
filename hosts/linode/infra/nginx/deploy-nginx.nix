{ pkgs, self }:

let
  nginxConf = ./nginx.conf;
  forgejoSite = ./sites-enabled/forgejo.conf;
  unitFile = ./nginx.service;

  deployScript = pkgs.writeShellScript "deploy-nginx" ''
    set -euo pipefail

    NGINX_BIN="$(nix build --no-link --print-out-paths ${self}#nginx)/bin/nginx"

    # Ensure directories exist
    sudo install -d -m 0755 /etc/nginx
    sudo install -d -m 0755 /etc/nginx/sites-enabled
    sudo install -d -m 0755 /var/log/nginx
    sudo install -d -m 0755 /var/lib/nginx

    # Install config
    sudo install -m 0644 ${nginxConf} /etc/nginx/nginx.conf
    sudo install -m 0644 ${forgejoSite} /etc/nginx/sites-enabled/forgejo.conf

    # Install unit and patch ExecStart
    sudo install -m 0644 ${unitFile} /etc/systemd/system/nginx-nix.service
    sudo sed -i "s|@NGINX_BIN@|$NGINX_BIN|g" /etc/systemd/system/nginx-nix.service

    sudo systemctl daemon-reload
    sudo systemctl enable --now nginx-nix.service

    sudo systemctl --no-pager status nginx-nix.service

    # Quick config test (nginx will already have started; this is just reassurance)
    sudo $NGINX_BIN -t -c /etc/nginx/nginx.conf
  '';
in
{
  nginx = pkgs.nginx;
  app = { type = "app"; program = toString deployScript; };
}

