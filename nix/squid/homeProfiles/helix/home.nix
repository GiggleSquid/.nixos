{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  packages = with nixpkgs; [
    nixd
    nixfmt-rfc-style
    vscode-langservers-extracted
    superhtml
    marksman
    taplo
    lua-language-server
    yaml-language-server
    bash-language-server
  ];
}
