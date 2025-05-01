{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.unimatrix ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "unimatrix.cephalonas.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "unimatrix"
      "borg"
    ];
  };
}
