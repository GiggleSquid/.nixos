{ inputs }:
let
  inherit (inputs) nixpkgs;
in
{
  services.k3s = {
    package = nixpkgs.k3s_1_29;
    enable = true;
    clusterInit = true;
    role = "server";
    extraFlags = toString [
      "--tls-san=10.10.4.30,consortium.cephalonetes.lan.gigglesquid.tech"
      "--disable=servicelb,traefik"
      "--disable-cloud-controller"
      "--flannel-backend=wireguard-native"
    ];
  };
}
