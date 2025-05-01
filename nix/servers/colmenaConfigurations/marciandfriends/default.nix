{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.marciandfriends ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "marciandfriends.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "website"
      "marciandfriends"
    ];
  };
}
