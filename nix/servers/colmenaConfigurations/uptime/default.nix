{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.uptime ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "uptime.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "uptime"
    ];
  };
}
