{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.vaultwarden ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "vaultwarden.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "vaultwarden"
    ];
  };
}
