{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.umami ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "umami.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "umami"
    ];
  };
}
