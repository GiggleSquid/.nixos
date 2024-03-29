{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  packages = with nixpkgs; [
    nixd
    nixfmt-rfc-style
    vscode-langservers-extracted
    marksman
    taplo
    lua-language-server
    # rust-analyzer
    yaml-language-server
  ];
}
