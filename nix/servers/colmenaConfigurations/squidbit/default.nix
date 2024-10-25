{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.squidbit ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.1.30";
    tags = (common.deployment.tags) ++ [
      "media"
      "squidbit"
    ];
  };
}
