{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.lb-1 ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "lb-1.lb.lan.gigglesquid.tech";
    tags = [
      "keepalived"
      "lb"
      "lb-b"
    ];
  };
}
