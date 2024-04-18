{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.cephalonetes-server-3 ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.10.4.33";
    tags = (common.deployment.tags) ++ [
      "k3s"
      "cluster"
      "cluster-server"
      "cephalonetes"
    ];
  };
}
