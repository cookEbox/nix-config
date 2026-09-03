{ pkgs, ... }:

let
  chatgpt = pkgs.callPackage ../../packages/chatgpt-linux { };
in
{
  environment.systemPackages = [
    chatgpt
  ];
}
