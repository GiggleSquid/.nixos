{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  home.packages = with nixpkgs; [
    ripgrep
    git
  ];
  home.shellAliases = {
    l = "lsd -Al";
    cat = "bat";
    mkdir = "mkdir -p";
  };
}
