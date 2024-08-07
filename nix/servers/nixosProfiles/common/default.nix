{ inputs }:
let
  inherit (inputs) nixpkgs;
in
{
  networking = {
    nameservers = [ "10.3.0.1" ];
    firewall = {
      enable = false;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };
}
