{
  inputs,
  cell,
}: let
  inherit (inputs) common;
  inherit (common.deployment) tags;
in {
  imports = [cell.nixosConfigurations.master1];
  inherit (common) bee;

  deployment = {
    buildOnTarget = false;
    targetHost = "10.10.4.31";
    tags = ["cephalonetes"] ++ tags;
  };
}
