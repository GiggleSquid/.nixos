{ inputs, config }:
let
  inherit (inputs) nixpkgs;
in
{
  sops.secrets."cephalonetes/k3s_token" = { };

  services.k3s = {
    package = nixpkgs.k3s_1_29;
    enable = true;
    role = "agent";
    tokenFile = config.sops.secrets."cephalonetes/k3s_token".path;
    serverAddr = "https://consortium.cephalonetes.lan.gigglesquid.tech:6443";
  };
}
