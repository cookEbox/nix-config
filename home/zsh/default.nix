{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    initContent = ''
      export PATH="$HOME/bin:$PATH"
    '';
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      cat = "bat";
      n = "nvim .";
      c = "clear";
      v = "nvim";
      sl = "lsd";
      ls = "lsd";
      l = "lsd -l";
      la = "lsd -lA";
      ll = "lsd -lAh";
      lt = "lsd --tree";
      ip = "ip --color=auto";
      upgrade = "cd ~/.config/nix-config/; sudo nix flake update; cd -";
      update = "cd ~/.config/nix-config/; sudo nixos-rebuild switch --flake '.#' --impure; cd -; source ~/.zshrc";
      clean = "cd ~/.config/nix-config/; sudo nixos-rebuild switch --flake '.#' --impure --upgrade; nix-collect-garbage -d; nix-store --optimise -vv; cd -";
      lockup = "cd ~/.config/nix-config/; nix build --recreate-lock-file; sudo nixos-rebuild switch --flake '.#' --impure --upgrade; nix-store --gc; nix-store --optimise -vv; cd -";
      config = "nvim ~/.config/nix-config/";
      add = "~/.config/nix-config/gitaddcommit.sh";
      push = "cd ~/.config/nix-config/; git push -u origin main; cd - ";
      server = "ssh nick@192.168.1.140";
      fware = "fwupdmgr";
      blank = "clear; cat >/dev/null";
      sql = "rlwrap sqlite3";
      syncup = "rclone copy /home/nick/Documents/Remote/Drive/ Drive:";
      syncdwn = "rclone copy Drive: /home/nick/Documents/Remote/Drive/";
      rpass = "< /dev/urandom tr -dc _A-Z-a-z-0-9'!\"#$%&()*+,-./:;<=>?@[\\]^_`{|}~' | head -c\${1:-32};echo;";
      ladybird = "/nix/store/1zjr98ippnh7j0vpiga2gpn2lgbk3pbm-ladybird-0-unstable-2025-03-27/bin/Ladybird";
      lb = "/nix/store/1zjr98ippnh7j0vpiga2gpn2lgbk3pbm-ladybird-0-unstable-2025-03-27/bin/Ladybird";
      };
    history = {
      size = 10000;
      path = "/home/nick/.config/zsh/history";
    };
    plugins = with pkgs; [
      {
        name = "formarks";
        src = fetchFromGitHub {
          owner = "wfxr";
          repo = "formarks";
          rev = "8abce138218a8e6acd3c8ad2dd52550198625944";
          sha256 = "1wr4ypv2b6a2w9qsia29mb36xf98zjzhp3bq4ix6r3cmra3xij90";
        };
        file = "formarks.plugin.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.6.0";
          sha256 = "0zmq66dzasmr5pwribyh4kbkk23jxbpdw4rjxx0i7dx8jjp2lzl4";
        };
        file = "zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-abbrev-alias";
        src = fetchFromGitHub {
          owner = "momo-lab";
          repo = "zsh-abbrev-alias";
          rev = "637f0b2dda6d392bf710190ee472a48a20766c07";
          sha256 = "16saanmwpp634yc8jfdxig0ivm1gvcgpif937gbdxf0csc6vh47k";
        };
        file = "abbrev-alias.plugin.zsh";
      }
      {
        name = "zsh-autopair";
        src = fetchFromGitHub {
          owner = "hlissner";
          repo = "zsh-autopair";
          rev = "34a8bca0c18fcf3ab1561caef9790abffc1d3d49";
          sha256 = "1h0vm2dgrmb8i2pvsgis3lshc5b0ad846836m62y8h3rdb3zmpy1";
        };
        file = "autopair.zsh";
      }
    ];
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
