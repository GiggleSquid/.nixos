{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.ns-root ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.10.3.10";
    tags = (common.deployment.tags) ++ [
      "dns"
      "ns"
    ];
  };
}
