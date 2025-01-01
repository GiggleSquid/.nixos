{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.thatferretblog ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.1.101";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "webserver"
      "thatferretblog"
    ];
  };
}
