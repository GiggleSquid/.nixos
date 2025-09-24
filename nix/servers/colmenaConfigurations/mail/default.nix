{ inputs, cell }:
let
  inherit (inputs) common;
in
{
  imports = [ cell.nixosConfigurations.mail ];
  inherit (common) bee;

  deployment = common.deployment // {
    targetHost = "mail.lan.gigglesquid.tech";
    tags = (common.deployment.tags) ++ [
      "mail"
      "mailserver"
    ];
  };
}
