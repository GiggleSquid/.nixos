{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.minesquid-velocity ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "velocity.minesquid.lan.gigglesquid.tech";
    tags = common.deployment.tags ++ [
      "minecraft"
      "minesquid-velocity"
    ];
  };
}
