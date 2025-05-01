{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.i2p ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "i2p.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [ "i2p" ];
  };
}
