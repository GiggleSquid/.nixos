{
  inputs,
  cell,
}: {
  systemPackages = with inputs.nixpkgs; [
    jq
    git
    direnv
    ripgrep
    curl
    wget
  ];
}
