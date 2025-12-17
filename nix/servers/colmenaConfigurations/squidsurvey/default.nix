{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.squidsurvey ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "squidsurvey.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "limesurvey"
    ];
  };
}
