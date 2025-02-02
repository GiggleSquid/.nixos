{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.crowdsec ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.0.50";
    tags = (common.deployment.tags) ++ [
      "crowdsec"
    ];
  };
}
