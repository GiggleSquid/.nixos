{
  inputs,
  cell,
}: {
  packages = with inputs.nixpkgs; [
    nil
    vscode-langservers-extracted
    marksman
    taplo
    lua-language-server
    nixfmt-rfc-style
    # rust-analyzer
    yaml-language-server
  ];
}
