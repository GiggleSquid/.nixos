{ inputs, cell }:
let
  inherit (inputs) rpi;
in
{
  imports = [ cell.nixosConfigurations.ns1 ];
  inherit (rpi) bee;

  deployment = rpi.deployment // {
    targetHost = "ns1.dns.lan.gigglesquid.tech";
    tags = [
      "all"
      "dns"
      "ns"
    ];
  };
}
