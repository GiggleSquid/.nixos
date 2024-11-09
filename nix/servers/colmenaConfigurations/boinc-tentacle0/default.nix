{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.boinc-tentacle0 ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.1.21";
    tags = (common.deployment.tags) ++ [ "boinc" ];
  };
}
