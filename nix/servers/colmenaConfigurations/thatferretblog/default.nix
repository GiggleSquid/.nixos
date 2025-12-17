{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.thatferretblog ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "thatferret.blog.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "thatferretblog"
    ];
  };
}
