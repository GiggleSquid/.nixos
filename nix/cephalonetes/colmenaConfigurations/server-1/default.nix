{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.server-1 ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.10.4.41";
    tags = (common.deployment.tags) ++ [
      "server"
      "cluster-init"
    ];
  };
}
