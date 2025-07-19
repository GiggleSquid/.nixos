{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.atuin ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "atuin.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [ "atuin" ];
  };
}
