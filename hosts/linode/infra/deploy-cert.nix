{ pkgs, self }:

let
  deployScript = pkgs.writeShellScript "deploy-cert" ''
    set -euo pipefail

    FORCE=0
    if [ "''${1:-}" = "--force" ]; then
      FORCE=1
      shift
    fi

    DOMAIN="''${1:?usage: deploy-cert [--force] <domain>}"

    COMMON_ENV_DIR="/var/lib/megaptera/deploy"
    COMMON_ENV="$COMMON_ENV_DIR/common.env"
    sudo install -d -m 0755 "$COMMON_ENV_DIR"

    if [ -f "$COMMON_ENV" ]; then
      # shellcheck disable=SC1090
      . "$COMMON_ENV"
    fi

    if [ -z "''${LE_EMAIL:-}" ]; then
      LE_EMAIL="hostmaster@$DOMAIN"
      echo "WARNING: LE_EMAIL not set in $COMMON_ENV; defaulting to: $LE_EMAIL" >&2
    fi

    CERTBOT_OUT="$(nix build --no-link --print-out-paths ${self}#certbot)"
    CERTBOT_BIN="$CERTBOT_OUT/bin/certbot"

    sudo install -d -m 0755 /var/lib/nginx/acme

    EXTRA=""
    if [ "$FORCE" -eq 1 ]; then
      EXTRA="--force-renewal"
      echo "Forcing renewal for $DOMAIN" >&2
    fi

    sudo "$CERTBOT_BIN" certonly --webroot \
      -w /var/lib/nginx/acme \
      -d "$DOMAIN" \
      --agree-tos --non-interactive \
      -m "$LE_EMAIL" \
      $EXTRA

    # Reload nginx so it picks up renewed certs (safe even if unchanged)
    sudo systemctl reload nginx-nix.service || sudo systemctl reload nginx || true
  '';
in {
  app = { type = "app"; program = toString deployScript; };
}

