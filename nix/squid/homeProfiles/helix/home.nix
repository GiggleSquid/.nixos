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
    alejandra
    # rust-analyzer
    yaml-language-server
  ];
}
