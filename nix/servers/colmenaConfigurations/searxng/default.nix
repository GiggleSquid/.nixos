{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.searxng ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "searx.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "searxng"
      "search"
    ];
  };
}
