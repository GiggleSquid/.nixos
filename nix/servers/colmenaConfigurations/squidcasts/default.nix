{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.squidcasts ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "10.3.1.32";
    tags = (common.deployment.tags) ++ [
      "media"
      "squidcasts"
    ];
  };
}
