{ pkgs, self }:

let
  deployScript = pkgs.writeShellScript "deploy-all" ''
    set -euo pipefail

    FORCE_RENEW=0

    usage() {
      echo "usage: deploy-all [--force-renew] <domain>" >&2
      exit 2
    }

    # Parse options (must come before <domain>)
    while [ $# -gt 0 ]; do
      case "$1" in
        --force-renew)
          FORCE_RENEW=1
          shift
          ;;
        -h|--help)
          usage
          ;;
        --)
          shift
          break
          ;;
        -*)
          echo "error: unknown option: $1" >&2
          usage
          ;;
        *)
          break
          ;;
      esac
    done

    DOMAIN="''${1:-}"
    if [ -z "$DOMAIN" ]; then
      echo "error: missing <domain>" >&2
      usage
    fi

    # minimal sanity check: must contain at least one dot
    if ! printf '%s' "$DOMAIN" | grep -q '\.'; then
      echo "error: invalid domain '$DOMAIN' (must contain a dot)" >&2
      exit 2
    fi
    shift

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

    CERTBOT_EXTRA=""
    if [ "$FORCE_RENEW" -eq 1 ]; then
      CERTBOT_EXTRA="--force-renewal"
      echo "NOTE: forcing certificate renewal for $DOMAIN" >&2
    fi

    # Non-interactive issuance/renewal
    sudo "$CERTBOT_BIN" certonly --webroot \
      -w /var/lib/nginx/acme \
      -d "$DOMAIN" \
      --agree-tos \
      --non-interactive \
      -m "$LE_EMAIL" \
      --keep-until-expiring \
      $CERTBOT_EXTRA

    echo "==> 3) Redeploy nginx (HTTPS should now be enabled)"
    nix run ${self}#deploy-nginx -- "$DOMAIN"

    echo "==> 4) Deploy Forgejo (hardened config + server-local secrets)"
    nix run ${self}#deploy-forgejo -- "$DOMAIN"

    echo "==> Done"
  '';
in {
  app = { type = "app"; program = toString deployScript; };
}

