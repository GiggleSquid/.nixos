{ inputs, config }:
let
  inherit (inputs) nixpkgs;
in
{
  sops.secrets."cephalonetes/k3s_token" = { };

  services.k3s = {
    package = nixpkgs.k3s_1_29;
    enable = true;
    role = "server";
    extraFlags = toString [
      "--tls-san=10.10.4.30,consortium.cephalonetes.lan.gigglesquid.tech"
      "--disable=servicelb,traefik"
      "--disable-cloud-controller"
      "--flannel-backend=wireguard-native"
      "--kube-proxy-arg='--proxy-mode=ipvs'"
      "--kube-proxy-arg='--ipvs-scheduler=rr'"
    ];
    tokenFile = config.sops.secrets."cephalonetes/k3s_token".path;
    serverAddr = "https://consortium.cephalonetes.lan.gigglesquid.tech:6443";
  };
}
