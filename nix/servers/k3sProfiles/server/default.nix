{ config }:
{
  sops.secrets."cephalonetes/k3s_token" = { };

  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = "--tls-san=10.10.4.30,consortium.cephalonetes.lan.gigglesquid.tech --disable=servicelb,traefik --disable-cloud-controller --flannel-backend=wireguard-native --kube-proxy-arg='--proxy-mode=ipvs' --kube-proxy-arg='--ipvs-scheduler=rr'";
    tokenFile = config.sops.secrets."cephalonetes/k3s_token".path;
    serverAddr = "https://consortium.cephalonetes.lan.gigglesquid.tech:6443";
  };
}
