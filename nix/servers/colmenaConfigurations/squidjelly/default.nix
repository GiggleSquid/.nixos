{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.squidjelly ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "squidjelly.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "media"
      "squidjelly"
    ];
  };
}
