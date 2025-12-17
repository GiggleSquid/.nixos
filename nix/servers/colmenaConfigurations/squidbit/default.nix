{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.squidbit ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "squidbit.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "squidbit"
    ];
  };
}
