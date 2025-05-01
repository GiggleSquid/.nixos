{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.squidcasts ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "squidcasts.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "media"
      "squidcasts"
    ];
  };
}
