{ inputs, cell }:
let
  inherit (inputs) rpi;
in
{
  imports = [ cell.nixosConfigurations.timesquid-0 ];
  inherit (rpi) bee;

  deployment = rpi.deployment // {
    targetHost = "10.3.0.5";
    tags = (rpi.deployment.tags) ++ [
      "ntp"
      "timesquid-0"
    ];
  };
}
