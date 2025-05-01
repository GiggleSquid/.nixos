{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.warrior-archiveteam ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "warrior.archiveteam.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "archive-team"
      "warrior"
    ];
  };
}
