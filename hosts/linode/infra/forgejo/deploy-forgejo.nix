# hosts/linode/infra/forgejo/deploy-forgejo.nix
{ pkgs, self }:

let
  appIniTemplate   = ./app.ini;
  serviceTemplate  = ./forgejo.service;

  deployScript = pkgs.writeShellScript "deploy-forgejo" ''
    set -euo pipefail

    DOMAIN="''${FORGEJO_DOMAIN:-forgejo.megaptera.dev}"

    echo "Deploying Forgejo for domain: $DOMAIN"

    # Build forgejo from this flake and capture the output path
    FORGEJO_OUT="$(nix build --no-link --print-out-paths ${self}#forgejo)"

    # Determine actual executable name (nixpkgs forgejo often provides bin/gitea)
    if [ -x "$FORGEJO_OUT/bin/forgejo" ]; then
      FORGEJO_BIN="$FORGEJO_OUT/bin/forgejo"
    elif [ -x "$FORGEJO_OUT/bin/gitea" ]; then
      FORGEJO_BIN="$FORGEJO_OUT/bin/gitea"
    else
      echo "ERROR: Could not find forgejo/gitea executable under: $FORGEJO_OUT" >&2
      echo "Contents of $FORGEJO_OUT/bin:" >&2
      ls -la "$FORGEJO_OUT/bin" >&2 || true
      echo "Candidate matches:" >&2
      find "$FORGEJO_OUT" -maxdepth 3 -type f \( -name forgejo -o -name gitea \) -print >&2 || true
      exit 1
    fi

    echo "Using Forgejo executable: $FORGEJO_BIN"

    if [ ! -x "$FORGEJO_BIN" ]; then
      echo "ERROR: Forgejo binary not found at: $FORGEJO_BIN" >&2
      exit 1
    fi

    # Create forgejo user/group if missing
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

    # Ensure dirs exist
    sudo install -d -m 0755 /etc/forgejo
    sudo install -d -m 0755 /var/lib/forgejo /var/log/forgejo
    sudo install -d -m 0755 /var/lib/forgejo/data /var/lib/forgejo/git /var/lib/forgejo/git/repositories

    # Ownership
    sudo chown -R forgejo:forgejo /var/lib/forgejo /var/log/forgejo

    # Render app.ini with domain
    sudo sed "s|@FORGEJO_DOMAIN@|$DOMAIN|g" ${appIniTemplate} \
      | sudo tee /etc/forgejo/app.ini >/dev/null
    sudo chmod 0644 /etc/forgejo/app.ini

    # Install systemd unit and patch binary path
    sudo install -m 0644 ${serviceTemplate} /etc/systemd/system/forgejo.service
    sudo sed -i "s|@FORGEJO_BIN@|$FORGEJO_BIN|g" /etc/systemd/system/forgejo.service

    sudo systemctl daemon-reload
    sudo systemctl enable forgejo.service
    sudo systemctl restart forgejo.service

    sudo systemctl --no-pager status forgejo.service
    echo
    echo "Forgejo should now be listening on 127.0.0.1:3000"
    echo "Next: nginx should proxy to it; if nginx shows 502, check: journalctl -u forgejo -e"
  '';
in
{
  forgejo = pkgs.forgejo;

  app = {
    type = "app";
    program = toString deployScript;
  };

  deploy = deployScript;
}

