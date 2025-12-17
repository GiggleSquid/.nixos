{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.attic ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "attic.lan.gigglesquid.tech";
    tags = [
      "caddy"
      "attic"
      "cache"
    ];
  };
}
