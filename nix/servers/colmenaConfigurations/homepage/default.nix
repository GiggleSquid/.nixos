{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.homepage ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "homepage.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "homepage"
      "dash"
    ];
  };
}
