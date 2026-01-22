# hosts/linode/infra/forgejo/deploy-forgejo.nix
{ pkgs, self }:

let
  appIniTemplate   = ./app.ini;
  serviceTemplate  = ./forgejo.service;

  deployScript = pkgs.writeShellScript "deploy-forgejo" ''
    set -euo pipefail

    DOMAIN="''${1:?usage: deploy-forgejo <domain>}"
    echo "Deploying Forgejo for domain: $DOMAIN"

    FORGEJO_OUT="$(nix build --no-link --print-out-paths ${self}#forgejo)"

    if [ -x "$FORGEJO_OUT/bin/forgejo" ]; then
      FORGEJO_BIN="$FORGEJO_OUT/bin/forgejo"
    elif [ -x "$FORGEJO_OUT/bin/gitea" ]; then
      FORGEJO_BIN="$FORGEJO_OUT/bin/gitea"
    else
      echo "ERROR: Could not find forgejo/gitea executable under: $FORGEJO_OUT" >&2
      ls -la "$FORGEJO_OUT/bin" >&2 || true
      exit 1
    fi
    echo "Using Forgejo executable: $FORGEJO_BIN"

    # user/group
    if ! getent group forgejo >/dev/null 2>&1; then
      sudo groupadd --system forgejo
    fi
    if ! id -u forgejo >/dev/null 2>&1; then
      sudo useradd --system \
        --gid forgejo \
        --home-dir /var/lib/forgejo \
        --create-home \
        --shell /usr/sbin/nologin \
        forgejo
    fi

    # dirs (no /etc/forgejo)
    sudo install -d -m 0750 -o forgejo -g forgejo /var/lib/forgejo/custom/conf
    sudo install -d -m 0755 /var/lib/forgejo/data /var/lib/forgejo/git/repositories
    sudo install -d -m 0755 /var/lib/forgejo/data/log
    sudo install -d -m 0755 /var/log/forgejo

    sudo chown -R forgejo:forgejo /var/lib/forgejo /var/log/forgejo

    SECRETS="/var/lib/forgejo/custom/conf/secrets.env"
    if [ ! -f "$SECRETS" ]; then
      echo "Generating Forgejo secrets: $SECRETS"

      INTERNAL_TOKEN="$(openssl rand -hex 32)"
      SECRET_KEY="$(openssl rand -hex 64)"
      OAUTH2_JWT_SECRET="$(openssl rand -base64 32 | tr -d '\n')"

      # Write atomically-ish via tee (no shell redirection)
      TMP_SECRETS="$(mktemp)"
      printf 'INTERNAL_TOKEN=%s\nSECRET_KEY=%s\nOAUTH2_JWT_SECRET=%s\n' \
        "$INTERNAL_TOKEN" "$SECRET_KEY" "$OAUTH2_JWT_SECRET" > "$TMP_SECRETS"

      sudo install -m 0600 -o root -g root "$TMP_SECRETS" "$SECRETS"
      rm -f "$TMP_SECRETS"
    fi

    INTERNAL_TOKEN="$(sudo awk -F= '$1=="INTERNAL_TOKEN"{print $2}' "$SECRETS")"
    SECRET_KEY="$(sudo awk -F= '$1=="SECRET_KEY"{print $2}' "$SECRETS")"
    OAUTH2_JWT_SECRET="$(sudo awk -F= '$1=="OAUTH2_JWT_SECRET"{print $2}' "$SECRETS")"

    # Sanity: fail fast if something went wrong
    if [ -z "$INTERNAL_TOKEN" ] || [ -z "$SECRET_KEY" ] || [ -z "$OAUTH2_JWT_SECRET" ]; then
      echo "ERROR: failed to load one or more secrets from $SECRETS" >&2
      sudo ls -l "$SECRETS" >&2 || true
      exit 1
    fi

    TMP="$(mktemp)"
    sed \
      -e "s|@FORGEJO_DOMAIN@|$DOMAIN|g" \
      -e "s|@INTERNAL_TOKEN@|$INTERNAL_TOKEN|g" \
      -e "s|@SECRET_KEY@|$SECRET_KEY|g" \
      -e "s|@OAUTH2_JWT_SECRET@|$OAUTH2_JWT_SECRET|g" \
      ${appIniTemplate} > "$TMP"

    sudo install -m 0640 -o forgejo -g forgejo "$TMP" /var/lib/forgejo/custom/conf/app.ini
    rm -f "$TMP"

    sudo install -m 0644 ${serviceTemplate} /etc/systemd/system/forgejo.service
    sudo sed -i "s|@FORGEJO_BIN@|$FORGEJO_BIN|g" /etc/systemd/system/forgejo.service

    sudo systemctl daemon-reload
    sudo systemctl enable forgejo.service
    sudo systemctl restart forgejo.service
    sudo systemctl --no-pager status forgejo.service
  '';
in {
  forgejo = pkgs.forgejo;
  app = { type = "app"; program = toString deployScript; };
}
