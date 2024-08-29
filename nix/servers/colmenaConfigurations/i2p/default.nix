{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.i2p ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.0.40";
    tags = (common.deployment.tags) ++ [ "i2p" ];
  };
}
