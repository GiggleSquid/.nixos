{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.server-3 ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.10.4.43";
    tags = (common.deployment.tags) ++ [ "server" ];
  };
}
