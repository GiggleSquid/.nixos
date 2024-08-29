{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.squidjelly ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.4.0.31";
    tags = (common.deployment.tags) ++ [
      "media"
      "squidjelly"
    ];
  };
}
