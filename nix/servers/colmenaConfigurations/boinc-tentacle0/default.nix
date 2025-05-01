{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.boinc-tentacle0 ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "boinc.tentacle0.kraken.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [ "boinc" ];
  };
}
