{ inputs }:
{
  environment.systemPackages = with inputs.nixpkgs; [
    libreoffice-qt6-fresh
    hunspell
    hunspellDicts.en_GB-ise
  ];
}
