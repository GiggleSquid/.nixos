{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  home.packages = with nixpkgs; [
    ripgrep
    git
    btop
  ];

  home.shellAliases = {
    l = "lsd -Al";
    mkdir = "mkdir -p";
  };
}
