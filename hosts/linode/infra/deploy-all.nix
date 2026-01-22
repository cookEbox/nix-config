{ pkgs, self }:

let
  deployScript = pkgs.writeShellScript "deploy-all" ''
    set -euo pipefail

    DOMAIN="''${1:?usage: deploy-all <domain>}"

    # Server-local deploy config (so deploy-all remains single-arg)
    COMMON_ENV_DIR="/var/lib/megaptera/deploy"
    COMMON_ENV="$COMMON_ENV_DIR/common.env"
    sudo install -d -m 0755 "$COMMON_ENV_DIR"

    # Optional: allow operator to set LE_EMAIL once.
    # If missing, default to hostmaster@DOMAIN (prints a warning).
    LE_EMAIL=""
    if [ -f "$COMMON_ENV" ]; then
      # shellcheck disable=SC1090
      . "$COMMON_ENV"
    fi
    if [ -z "''${LE_EMAIL:-}" ]; then
      LE_EMAIL="hostmaster@$DOMAIN"
      echo "WARNING: LE_EMAIL not set in $COMMON_ENV; defaulting to: $LE_EMAIL" >&2
      echo "         Set it once by creating $COMMON_ENV with: LE_EMAIL=you@domain" >&2
    fi

    echo "==> 1) Deploy nginx (HTTP bootstrap / ACME webroot) for $DOMAIN"
    nix run ${self}#deploy-nginx -- "$DOMAIN"

    echo "==> 2) Obtain/renew Let's Encrypt cert for $DOMAIN"
    CERTBOT_OUT="$(nix build --no-link --print-out-paths ${self}#certbot)"
    CERTBOT_BIN="$CERTBOT_OUT/bin/certbot"

    # Make sure the webroot exists (deploy-nginx also creates it)
    sudo install -d -m 0755 /var/lib/nginx/acme

    # Non-interactive issuance/renewal
    sudo "$CERTBOT_BIN" certonly --webroot \
      -w /var/lib/nginx/acme \
      -d "$DOMAIN" \
      --agree-tos \
      --non-interactive \
      -m "$LE_EMAIL" \
      --keep-until-expiring

    echo "==> 3) Redeploy nginx (HTTPS should now be enabled)"
    nix run ${self}#deploy-nginx -- "$DOMAIN"

    echo "==> 4) Deploy Forgejo (hardened config + server-local secrets)"
    nix run ${self}#deploy-forgejo -- "$DOMAIN"

    echo "==> Done"
  '';
in {
  app = { type = "app"; program = toString deployScript; };
}

