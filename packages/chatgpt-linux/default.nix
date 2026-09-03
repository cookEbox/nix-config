{
  lib,
  stdenv,
  stdenvNoCC,
  fetchurl,
  writeShellApplication,

  # Build hooks / tools
  autoPatchelfHook,
  makeWrapper,
  wrapGAppsHook3,
  dpkg,

  # Runtime libraries required by the packaged Electron app
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  dconf,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libgbm,
  libnotify,
  libusb1,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  pango,
  qt6,
  systemdLibs,

  # Runtime tools / libraries
  bubblewrap,
  libGL,
  libpulseaudio,
  libsecret,
  nodejs-slim,
  pipewire,
  ripgrep,
  tectonic-unwrapped,
  vulkan-loader,
  xdg-utils,
}:

let
  version = "26.818.31338";

  launcher = writeShellApplication {
    name = "chatgpt-launcher";

    text = ''
      : "''${CHATGPT_EXECUTABLE:?}"
      : "''${CHATGPT_RESOURCES_SOURCE:?}"
      : "''${CHATGPT_RESOURCES_CACHE_KEY:?}"

      cacheHome="''${XDG_CACHE_HOME:-''${HOME:?XDG_CACHE_HOME and HOME are unset}/.cache}"
      cacheRoot="$cacheHome/chatgpt/bundled-plugins"
      resourcesPath="$cacheRoot/$CHATGPT_RESOURCES_CACHE_KEY"

      # Electron rewrites bundled plugin manifests at runtime.
      #
      # The Nix store is immutable, so create a writable cached copy of the
      # resources which ChatGPT needs to modify.
      if [[ ! -f "$resourcesPath/.complete" ]]; then
        mkdir -p "$cacheRoot"

        stagingPath="$(
          mktemp -d \
            "$cacheRoot/.staging-$CHATGPT_RESOURCES_CACHE_KEY.XXXXXXXX"
        )"

        trap 'rm -rf -- "$stagingPath"' EXIT

        ln -s \
          "$CHATGPT_RESOURCES_SOURCE/"{codex,codex-code-mode-host,cua_node,native,rg} \
          "$stagingPath"

        cp -R \
          "$CHATGPT_RESOURCES_SOURCE/plugins" \
          "$stagingPath/plugins"

        chmod -R u+w "$stagingPath/plugins"

        touch "$stagingPath/.complete"

        if mv -T "$stagingPath" "$resourcesPath" 2>/dev/null; then
          trap - EXIT
        elif [[ -f "$resourcesPath/.complete" ]]; then
          rm -rf -- "$stagingPath"
          trap - EXIT
        else
          echo \
            "Failed to publish ChatGPT's writable bundled-plugin resources" \
            >&2
          exit 1
        fi
      fi

      export CODEX_ELECTRON_BUNDLED_PLUGINS_RESOURCES_PATH="$resourcesPath"

      # Your nixBox currently runs X11, so normally this will remain empty.
      # Keeping the Wayland handling makes the package portable if you change
      # session type later.
      waylandFlags=()

      if [[ -n "''${NIXOS_OZONE_WL:-}" && -n "''${WAYLAND_DISPLAY:-}" ]]; then
        waylandFlags=(
          --ozone-platform-hint=auto
          --enable-features=WaylandWindowDecorations
          --enable-wayland-ime=true
        )
      fi

      exec "$CHATGPT_EXECUTABLE" "''${waylandFlags[@]}" "$@"
    '';
  };

in
stdenvNoCC.mkDerivation {
  pname = "chatgpt";
  inherit version;

  src = fetchurl {
    url =
      "https://persistent.oaistatic.com/codex-app-prod/linux/deb/latest/chatgpt_amd64.deb";

    hash = "sha256-Q4J4SKdHJLVyvn+NyVRpirLMCRb3+dWZGg7oKJlE+Vs=";
  };

  strictDeps = true;

  # autoPatchelf moves PT_INTERP far enough that the detect-libc code used by
  # @parcel/watcher can take a fallback path through process.report. Under
  # Electron this can trip Chromium CFI and produce SIGILL when opening
  # Git-backed Codex projects.
  #
  # Force the bundled watcher to use its glibc backend.
  #
  # The grep deliberately acts as a guard: if OpenAI changes app.asar so the
  # expected code no longer exists, the build should fail rather than silently
  # applying an obsolete workaround.
  postPatch = ''
    grep -aFq \
      'const family = familySync();' \
      usr/lib/chatgpt/resources/app.asar

    sed -i \
      "s|const family = familySync();|const family = 'glibc'     ;|" \
      usr/lib/chatgpt/resources/app.asar
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    makeWrapper
    qt6.wrapQtAppsHook
    wrapGAppsHook3
  ];

  buildInputs = [
    (lib.getLib stdenv.cc.cc)

    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    dconf
    expat
    gdk-pixbuf
    glib
    gtk3
    libgbm
    libnotify
    libusb1
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
    qt6.qtbase
    systemdLibs
  ];

  # The dpkg unpack hook extracts the .deb into root/.
  sourceRoot = "root";

  # We apply both wrapper argument sets ourselves in postFixup.
  dontWrapGApps = true;
  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"

    # The Debian package contains /usr/bin, /usr/lib, /usr/share etc.
    cp -r usr/* "$out"

    # ChatGPT ships an unused Qt 5 fallback compatibility shim.
    rm -f "$out/lib/chatgpt/libqt5_shim.so"

    # The Debian package contains native modules for several combinations of
    # libc/platform. This derivation targets x86_64 Linux with glibc, so remove
    # musl and Android binaries before autoPatchelf examines them.
    rm -f \
      "$out/lib/chatgpt/resources/app.asar.unpacked/node_modules/@worklouder/device-kit-oai/node_modules/@worklouder/wl-device-kit/node_modules/serialport/node_modules/@serialport/bindings-cpp/prebuilds/"{linux-*/node.napi.musl.node,android-*/node.napi.*.node} \
      "$out/lib/chatgpt/resources/app.asar.unpacked/node_modules/@worklouder/device-kit-oai/node_modules/@worklouder/wl-device-kit/node_modules/node-hid/prebuilds/"{HID,HID_hidraw}-linux-*-musl/node-napi-v4.node \
      "$out/lib/chatgpt/resources/plugins/openai-bundled/plugins/"{browser,chrome}"/scripts/node_modules/classic-level/prebuilds/"{linux-*/classic-level.musl.node,android-*/classic-level.*.node}

    # Replace a few bundled tools with their Nix-managed equivalents.
    ln -sf \
      ${lib.getExe tectonic-unwrapped} \
      "$out/lib/chatgpt/resources/plugins/openai-bundled/plugins/latex/bin/tectonic"

    ln -sf \
      ${lib.getExe ripgrep} \
      "$out/lib/chatgpt/resources/rg"

    ln -sf \
      ${lib.getExe nodejs-slim} \
      "$out/lib/chatgpt/resources/cua_node/bin/node"

    # Expose the wrapper as the command users actually run.
    install -Dm755 \
      ${lib.getExe launcher} \
      "$out/bin/chatgpt"

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/chatgpt" \
      "''${gappsWrapperArgs[@]}" \
      "''${qtWrapperArgs[@]}" \
      --set CHATGPT_EXECUTABLE "$out/lib/chatgpt/ChatGPT" \
      --set CHATGPT_RESOURCES_SOURCE "$out/lib/chatgpt/resources" \
      --set CHATGPT_RESOURCES_CACHE_KEY "${version}-x86_64-linux" \
      --prefix PATH : ${
        lib.makeBinPath [
          nodejs-slim
          xdg-utils
          bubblewrap
        ]
      } \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          libGL
          libnotify
          libpulseaudio
          libsecret
          pipewire
          vulkan-loader
        ]
      } \
      --set-default CODEX_BROWSER_USE_NODE_PATH ${lib.getExe nodejs-slim} \
      --set-default NODE_REPL_NODE_PATH ${lib.getExe nodejs-slim}
  '';

  # These are upstream prebuilt binaries. Stripping them provides no benefit
  # and can interfere with bundled native components.
  dontStrip = true;

  meta = {
    description = "Desktop application for ChatGPT";
    homepage = "https://developers.openai.com/codex/app";
    license = lib.licenses.unfree;

    platforms = [
      "x86_64-linux"
    ];

    sourceProvenance = with lib.sourceTypes; [
      binaryNativeCode
    ];

    mainProgram = "chatgpt";
  };
}
