{inputs}: {
  systemPackages = with inputs.nixpkgs; [
    jq
    git
    direnv
    ripgrep
    unzip
    curl
    wget
    ventoy
  ];
}
