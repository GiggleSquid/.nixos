{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.search ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "search.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "caddy"
      "searxng"
      "search"
    ];
  };
}
