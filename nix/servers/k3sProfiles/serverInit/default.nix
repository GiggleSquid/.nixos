{
  services.k3s = {
    enable = true;
    clusterInit = true;
    role = "server";
    extraFlags = "--tls-san=10.10.4.30,consortium.cephalonetes.lan.gigglesquid.tech --disable=servicelb,traefik --disable-cloud-controller --flannel-backend=wireguard-native";
  };
}
