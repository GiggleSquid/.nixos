{
  inputs,
  cell,
}: let
  inherit (inputs) common;
in {
  imports = [cell.nixosConfigurations.timesquid-0];
  inherit (common) bee;

  deployment =
    common.deployment
    // {
      targetHost = "10.10.3.5";
      tags = (common.deployment.tags) ++ ["ntp"];
    };
}
