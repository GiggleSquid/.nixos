{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.minesquid-servers ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "servers.minesquid.lan.gigglesquid.tech";
    tags = common.deployment.tags ++ [
      "minecraft"
      "minesquid-servers"
    ];
  };
}
