{ config }:
{
  sops.secrets."cephalonetes/k3s_token" = { };

  services.k3s = {
    enable = true;
    role = "agent";
    tokenFile = config.sops.secrets."cephalonetes/k3s_token".path;
    serverAddr = "https://consortium.cephalonetes.lan.gigglesquid.tech:6443";
  };
}
