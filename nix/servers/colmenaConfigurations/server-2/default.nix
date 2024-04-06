{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.server-2 ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.10.4.42";
    tags = (common.deployment.tags) ++ [ "server" ];
  };
}
