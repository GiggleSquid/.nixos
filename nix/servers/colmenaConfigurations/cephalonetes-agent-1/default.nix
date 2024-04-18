{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.cephalonetes-agent-1 ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.10.4.41";
    tags = (common.deployment.tags) ++ [
      "k3s"
      "cluster"
      "cluster-agent"
      "cephalonetes"
    ];
  };
}
