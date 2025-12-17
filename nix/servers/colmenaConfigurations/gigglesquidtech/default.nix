{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.gigglesquidtech ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "gigglesquid.tech.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "gigglesquidtech"
    ];
  };
}
