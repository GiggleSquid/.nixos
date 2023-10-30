{
  inputs,
  cell,
}: let
  inherit (inputs) common;
  inherit (common) deployment;
in {
  imports = [cell.nixosConfigurations.squid-rig];
  inherit (common) bee;

  deployment =
    deployment
    // {
      targetHost = null;
      tags = (common.deployment.tags) ++ ["main" "squid"];
    };
}
