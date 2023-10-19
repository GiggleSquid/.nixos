{
  inputs,
  cell,
}: {
  systemPackages = with inputs.nixpkgs; [
    protonup-qt
    protontricks
    lutris
  ];
}
