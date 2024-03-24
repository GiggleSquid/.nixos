{ inputs }:
let
  inherit (inputs) nixpkgs;
in
{
  networking = {
    nameservers = [
      "10.10.3.11"
      "10.10.3.12"
    ];
    firewall = {
      enable = false;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };
}
