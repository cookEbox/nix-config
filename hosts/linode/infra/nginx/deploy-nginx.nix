{ pkgs, self }:

let
  nginxConf = ./nginx.conf;

  forgejoSiteHttp  = ./sites-enabled/forgejo-http.conf;
  forgejoSiteHttps = ./sites-enabled/forgejo-https.conf;

  unitFile = ./nginx.service;

  deployScript = pkgs.writeShellScript "deploy-nginx" ''
    set -euo pipefail

    # Build nginx from this flake and capture the output path
    NGINX_OUT="$(nix build --no-link --print-out-paths ${self}#nginx)"
    NGINX_BIN="$NGINX_OUT/bin/nginx"

    # Find mime.types in the nginx derivation output
    if [ -f "$NGINX_OUT/conf/mime.types" ]; then
      MIME_SRC="$NGINX_OUT/conf/mime.types"
    elif [ -f "$NGINX_OUT/share/nginx/mime.types" ]; then
      MIME_SRC="$NGINX_OUT/share/nginx/mime.types"
    else
      echo "ERROR: mime.types not found in nginx output: $NGINX_OUT" >&2
      exit 1
    fi

    # Ensure directories exist (config + logs + state + ACME + service hardening)
    sudo install -d -m 0755 /etc/nginx
    sudo install -d -m 0755 /etc/nginx/sites-available
    sudo install -d -m 0755 /etc/nginx/sites-enabled
    sudo install -d -m 0755 /var/log/nginx
    sudo install -d -m 0755 /var/lib/nginx
    sudo install -d -m 0755 /var/lib/nginx/acme
    sudo install -d -m 0755 /etc/letsencrypt

    # Install support files expected by nginx.conf
    sudo install -m 0644 "$MIME_SRC" /etc/nginx/mime.types

    # Install main nginx config
    sudo install -m 0644 ${nginxConf} /etc/nginx/nginx.conf

    # Install site configs into sites-available
    sudo install -m 0644 ${forgejoSiteHttp}  /etc/nginx/sites-available/forgejo-http.conf
    sudo install -m 0644 ${forgejoSiteHttps} /etc/nginx/sites-available/forgejo-https.conf

    # Remove legacy single-file name if it exists
    sudo rm -f /etc/nginx/sites-enabled/forgejo.conf \
           /etc/nginx/sites-enabled/forgejo-https.conf \
           /etc/nginx/sites-enabled/forgejo-http.conf || true
    sudo rm -f /etc/nginx/sites-available/forgejo.conf || true

    # Always enable HTTP bootstrap site
    sudo ln -sf /etc/nginx/sites-available/forgejo-http.conf /etc/nginx/sites-enabled/forgejo-http.conf

    # Enable HTTPS site only if certs exist
    DOMAIN="''${FORGEJO_DOMAIN:-git.example.com}"
    CERT_DIR="/etc/letsencrypt/live/$DOMAIN"

    if [ -f "$CERT_DIR/fullchain.pem" ] && [ -f "$CERT_DIR/privkey.pem" ]; then
      sudo ln -sf /etc/nginx/sites-available/forgejo-https.conf /etc/nginx/sites-enabled/forgejo-https.conf
    else
      sudo rm -f /etc/nginx/sites-enabled/forgejo-https.conf || true
    fi

    # Install unit and patch @NGINX_BIN@
    sudo install -m 0644 ${unitFile} /etc/systemd/system/nginx-nix.service
    sudo sed -i "s|@NGINX_BIN@|$NGINX_BIN|g" /etc/systemd/system/nginx-nix.service

    sudo systemctl daemon-reload

    # Validate config before (re)starting service
    sudo "$NGINX_BIN" -t -c /etc/nginx/nginx.conf

    # Start/restart
    sudo systemctl enable nginx-nix.service
    sudo systemctl restart nginx-nix.service

    # Status
    sudo systemctl --no-pager status nginx-nix.service
  '';
in
{
  nginx = pkgs.nginx;
  app = { type = "app"; program = toString deployScript; };
}
