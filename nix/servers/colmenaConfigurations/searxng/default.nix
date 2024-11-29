{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.searxng ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.1.50";
    tags = (common.deployment.tags) ++ [
      "searxng"
      "search"
    ];
  };
}
