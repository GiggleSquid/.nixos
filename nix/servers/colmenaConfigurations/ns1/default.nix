{ inputs, cell }:
let
  inherit (inputs) rpi;
in
{
  imports = [ cell.nixosConfigurations.ns1 ];
  inherit (rpi) bee;

  deployment = rpi.deployment // {
    targetHost = "10.3.0.11";
    tags = (rpi.deployment.tags) ++ [
      "dns"
      "ns"
    ];
  };
}
