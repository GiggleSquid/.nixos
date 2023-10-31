{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib // builtins;
in {
  fish = {
    enable = true;
    interactiveShellInit = ''${lib.getExe nixpkgs.starship} init fish | source'';
    functions = {
      starship_transient_rprompt_func = ''
        starship module time
      '';
    };
    plugins = [
      {
        name = "sponge";
        src = nixpkgs.fishPlugins.sponge.src;
      }
      {
        name = "colored-man-pages";
        src = nixpkgs.fishPlugins.colored-man-pages.src;
      }
      {
        name = "z";
        src = nixpkgs.fishPlugins.z.src;
      }
    ];
  };

  bash = {
    enable = true;
  };

  k9s = {
    enable = true;
  };

  lsd = {
    enable = true;
    enableAliases = true;
    settings = {
      total-size = true;
    };
  };
}
