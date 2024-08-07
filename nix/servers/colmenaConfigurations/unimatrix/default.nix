{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.unimatrix ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.1.27";
    tags = (common.deployment.tags) ++ [
      "unimatrix"
      "borg"
    ];
  };
}
