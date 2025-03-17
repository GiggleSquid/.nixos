{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.gigglesquidtech ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.1.100";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "webserver"
      "gigglesquidtech"
    ];
  };
}
