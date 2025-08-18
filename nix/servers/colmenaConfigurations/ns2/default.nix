{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.ns2 ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "ns2.dns.lan.gigglesquid.tech";
    tags = [
      "all"
      "dns"
      "ns"
    ];
  };
}
