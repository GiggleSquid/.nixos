{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.thatferretshop ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "thatferret.shop.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "thatferretshop"
    ];
  };
}
