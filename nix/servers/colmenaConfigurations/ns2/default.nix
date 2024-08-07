{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.ns2 ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.0.12";
    tags = (common.deployment.tags) ++ [
      "dns"
      "ns"
    ];
  };
}
