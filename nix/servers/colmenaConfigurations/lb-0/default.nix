{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.lb-0 ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "lb-0.lb.lan.gigglesquid.tech";
    tags = [
      "keepalived"
      "lb"
      "lb-a"
    ];
  };
}
