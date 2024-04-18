{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.cephalonetes-agent-2 ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.10.4.42";
    tags = (common.deployment.tags) ++ [
      "k3s"
      "cluster"
      "cluster-agent"
      "cephalonetes"
    ];
  };
}
