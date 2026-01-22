{ pkgs, self }:

let
  nginxConf = ./nginx.conf;

  forgejoSiteHttp  = ./sites-enabled/forgejo-http.conf;
  forgejoSiteHttps = ./sites-enabled/forgejo-https.conf;

  unitFile = ./nginx.service;

  deployScript = pkgs.writeShellScript "deploy-nginx" ''
    set -euo pipefail

    DOMAIN="''${FORGEJO_DOMAIN:-forgejo.megaptera.dev}"

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

    # Ensure directories exist
    sudo install -d -m 0755 /etc/nginx /etc/nginx/sites-available /etc/nginx/sites-enabled
    sudo install -d -m 0755 /var/log/nginx /var/lib/nginx /var/lib/nginx/acme /etc/letsencrypt

    # Support files expected by nginx.conf
    sudo install -m 0644 "$MIME_SRC" /etc/nginx/mime.types

    # Main nginx config
    sudo install -m 0644 ${nginxConf} /etc/nginx/nginx.conf

    # Render templated site configs into sites-available
    sudo sed "s|@FORGEJO_DOMAIN@|$DOMAIN|g" ${forgejoSiteHttp} \
      | sudo tee /etc/nginx/sites-available/forgejo-http.conf >/dev/null
    sudo sed "s|@FORGEJO_DOMAIN@|$DOMAIN|g" ${forgejoSiteHttps} \
      | sudo tee /etc/nginx/sites-available/forgejo-https.conf >/dev/null
    sudo chmod 0644 /etc/nginx/sites-available/forgejo-http.conf /etc/nginx/sites-available/forgejo-https.conf

    # Reset managed enabled sites (avoid stale state)
    sudo rm -f /etc/nginx/sites-enabled/forgejo-http.conf /etc/nginx/sites-enabled/forgejo-https.conf || true

    # Always enable HTTP bootstrap site
    sudo ln -sf /etc/nginx/sites-available/forgejo-http.conf /etc/nginx/sites-enabled/forgejo-http.conf

    # Enable HTTPS site only if certs exist
    CERT_DIR="/etc/letsencrypt/live/$DOMAIN"
    FULLCHAIN="$CERT_DIR/fullchain.pem"
    PRIVKEY="$CERT_DIR/privkey.pem"

    echo "Deploying nginx for domain: $DOMAIN"
    echo "Checking certs:"
    echo "  FULLCHAIN=$FULLCHAIN"
    echo "  PRIVKEY=$PRIVKEY"

    if sudo test -f "$FULLCHAIN" && sudo test -f "$PRIVKEY"; then
      echo "TLS: enabled (certs found)"
      sudo ln -sf /etc/nginx/sites-available/forgejo-https.conf /etc/nginx/sites-enabled/forgejo-https.conf
    else
      echo "WARNING: TLS not enabled yet (certs not found). Serving HTTP only."
      sudo ls -la "$CERT_DIR" || true
    fi

    # Install unit and patch @NGINX_BIN@
    sudo install -m 0644 ${unitFile} /etc/systemd/system/nginx-nix.service
    sudo sed -i "s|@NGINX_BIN@|$NGINX_BIN|g" /etc/systemd/system/nginx-nix.service

    sudo systemctl daemon-reload

    # Validate config before restart
    sudo "$NGINX_BIN" -t -c /etc/nginx/nginx.conf

    # Restart nginx
    sudo systemctl enable nginx-nix.service
    sudo systemctl restart nginx-nix.service

    sudo systemctl --no-pager status nginx-nix.service
  '';
in
{
  nginx = pkgs.nginx;
  app = { type = "app"; program = toString deployScript; };
}

