{
  inputs,
  cell,
}: let
  inherit (inputs) common;
  inherit (common) deployment;
in {
  imports = [cell.nixosConfigurations.squid-top];
  inherit (common) bee;

  deployment =
    deployment
    // {
      targetHost = "10.10.10.211";
      tags = (common.deployment.tags) ++ ["laptop" "squid-top"];
    };
}
