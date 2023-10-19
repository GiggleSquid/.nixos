{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  security.polkit.enable = true;

  environment.systemPackages = with nixpkgs; [
    libsForQt5.polkit-kde-agent
  ];
}
