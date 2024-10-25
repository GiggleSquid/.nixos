{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.minesquid-servers ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.1.41";
    tags = common.deployment.tags ++ [
      "minecraft"
      "minesquid-servers"
    ];
  };
}
