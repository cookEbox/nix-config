#!/usr/bin/env bash

# Check if at least one argument is provided
if [ $# -eq 0 ]; then
  echo "Error: No argument provided. Please provide an argument."
  exit 1
fi

# Use the argument provided in your script
argument="$1"

mkdir $argument
cd $argument

git init
# touch name.txt
# echo $arguement > name.txt

touch bsync.sh
chmod +x bsync.sh

cat<<EOF > bsync.sh
#!/usr/bin/env bash

process=\$(pidof $argument)
kill -15 \$process

nix build
./result/bin/$argument &

set -o errexit
set -o nounset

keystroke="CTRL+F5"

# set to whatever's given as argument, defaults to firefox
BROWSER="\${1:-firefox}"

# find all visible browser windows
browser_windows="\$(xdotool search --sync --all --onlyvisible --name \${BROWSER})"

# Send keystroke
for bw in \$browser_windows; do
    xdotool key --window "\$bw" "\$keystroke"
done
EOF

nix-shell --packages ghc --run 'cabal init -n --libandexe --tests --no-comments'

touch "$argument.cabal"

cat <<EOF > "$argument.cabal"
cabal-version:      3.0
name:               $argument
version:            0.1.0.0
-- synopsis:
-- description:
license:            NONE
author:             nj.cooke@outlook.com
maintainer:         Nick Cooke
-- copyright:
build-type:         Simple
extra-doc-files:    CHANGELOG.md
-- extra-source-files:

common warnings
    ghc-options: -Wall

library
    import:           warnings
    exposed-modules:  MyLib
    -- other-modules:
    -- other-extensions:
    build-depends:    
        base ^>=4.16.4.0
      , warp
      , wai
      , http-media
      , http-types
      , lucid
      , lucid-htmx
      , text
      , servant
      , servant-server
      , servant-lucid
      , string-conversions
    hs-source-dirs:   src
    default-language: Haskell2010

executable $argument
    import:           warnings
    main-is:          Main.hs
    -- other-modules:
    -- other-extensions:
    build-depends:
        base ^>=4.16.4.0
      , $argument
      , warp
      , wai
      , http-media
      , http-types
      , lucid
      , lucid-htmx
      , text
      , servant
      , servant-server
      , servant-lucid
      , string-conversions

    hs-source-dirs:   app
    default-language: Haskell2010

test-suite $argument-test
    import:           warnings
    default-language: Haskell2010
    -- other-modules:
    -- other-extensions:
    type:             exitcode-stdio-1.0
    hs-source-dirs:   test
    main-is:          Main.hs
    build-depends:
        base ^>=4.16.4.0,
        $argument
EOF

touch flake.nix

cat <<EOF > flake.nix
{
  description = "My haskell application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.\${system};

        haskellPackages = pkgs.haskellPackages;

        jailbreakUnbreak = pkg:
          pkgs.haskell.lib.doJailbreak (pkg.overrideAttrs (_: { meta = { }; }));

        packageName = "$argument";
      in {
        packages.\${packageName} =
          haskellPackages.callCabal2nix packageName self rec {
            # Dependency overrides go here
          };

        packages.default = self.packages.\${system}.\${packageName};
        defaultPackage = self.packages.\${system}.default;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            haskellPackages.haskell-language-server # you must build it with your ghc to work
            haskellPackages.hoogle
            xdotool
            ghcid
            cabal-install
          ];
          inputsFrom = map (__getAttr "env") (__attrValues self.packages.\${system});
        };
        devShell = self.devShells.\${system}.default;
      });
}
EOF

mkdir app
touch app/Main.hs

cat <<EOF > app/Main.hs
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Network.Wai.Handler.Warp (run)
import Servant
import Servant.HTML.Lucid (HTML)
import Lucid
import Data.Text (Text) 
import Lucid.Htmx
import Lucid.Base (makeAttribute)
--import Data.String.Conversions (cs)

hxVars_ :: Text -> Attribute
hxVars_ = makeAttribute "hx-vars"

type API = Get '[HTML] (Html ())

server :: Server API
server = mainPage

mainPage :: Handler (Html ())
mainPage = 
  return $ do
    doctypehtml_ $ do
      head_ $ do
        title_ "HTMX Hello World"
        script_ [src_ "https://unpkg.com/htmx.org@1.9.6"] ("" :: Text)
      body_ $ do div_ "Hello World"
  

app :: Application
app = serve (Proxy :: Proxy API) server

main :: IO ()
main = do
    putStrLn "Running on http://localhost:8080"
    run 8080 app
EOF

git add .
git commit -m 'initial commit'
tmux
