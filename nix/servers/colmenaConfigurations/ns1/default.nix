{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.ns1 ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.10.3.11";
    tags = (common.deployment.tags) ++ [
      "dns"
      "ns"
    ];
  };
}
