{
  inputs,
  cell,
}: let
  inherit (inputs) common;
in {
  imports = [cell.nixosConfigurations.master-1];
  inherit (common) bee;

  deployment =
    common.deployment
    // {
      targetHost = "10.10.4.31";
      tags = (common.deployment.tags) ++ ["master"];
    };
}
