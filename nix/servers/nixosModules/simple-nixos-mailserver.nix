{ inputs, cell }:
{
  imports = [ inputs.simple-nixos-mailserver.nixosModules.mailserver ];
}
