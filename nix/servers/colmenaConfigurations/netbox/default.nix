{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.netbox ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "netbox.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "netbox"
    ];
  };
}
