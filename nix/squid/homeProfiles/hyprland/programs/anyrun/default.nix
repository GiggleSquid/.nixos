{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib // builtins;
in {
  enable = true;
  config = {
    plugins = with inputs.anyrun.packages.${nixpkgs.system}; [
      applications
      dictionary
      kidex
      rink
      shell
      stdin
    ];

    y.absolute = 50;
    #hidePluginInfo = true;
    closeOnClick = true;
  };

  extraCss = lib.readFile ./_style.css;
}
