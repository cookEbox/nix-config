{
  services.keyd = {
    enable = true;

    keyboards.default = {
      ids = [ "*" ];

      settings = {
        meta = {
          c = "C-c";
          v = "C-S-v";
        };
      };
    };
  };
}
