{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.marciandfriends ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.1.102";
    tags = (common.deployment.tags) ++ [
      "website"
      "marciandfriends"
    ];
  };
}
