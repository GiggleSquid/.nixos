{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.ncps ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "ncps.lan.gigglesquid.tech";
    tags = [
      "caddy"
      "ncps"
      "cache"
    ];
  };
}
