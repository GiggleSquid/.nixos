{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.warrior-archiveteam ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.1.60";
    tags = (common.deployment.tags) ++ [
      "archive-team"
      "warrior"
    ];
  };
}
