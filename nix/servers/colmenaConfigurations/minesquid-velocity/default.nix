{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.minesquid-velocity ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.1.40";
    tags = common.deployment.tags ++ [
      "minecraft"
      "minesquid-velocity"
    ];
  };
}
