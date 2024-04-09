{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.cephalonetes-longhorn-3 ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.10.4.43";
    tags = (common.deployment.tags) ++ [
      "rke2"
      "cluster"
      "cluster-longhorn"
      "cephalonetes"
    ];
  };
}
