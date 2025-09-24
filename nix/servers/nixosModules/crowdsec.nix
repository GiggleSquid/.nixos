{ inputs }:
{

  disabledModules = [ "services/security/crowdsec.nix" ];
  imports = [
    inputs.crowdsec.nixosModules.crowdsec
    inputs.crowdsec.nixosModules.crowdsec-firewall-bouncer
  ];
}
