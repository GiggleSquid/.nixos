{
  inputs,
  cell,
}: let
  inherit (inputs) common;
  inherit (common.deployment) tags;
in {
  imports = [cell.nixosConfigurations.squid-rig];
  inherit (common) bee;

  deployment = {
    buildOnTarget = true;
    allowLocalDeployment = true;
    targetHost = "10.10.10.10";
    tags = ["main" "squid"] ++ tags;
  };
}
