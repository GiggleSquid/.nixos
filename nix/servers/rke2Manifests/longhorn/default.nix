{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib // builtins;
in
{
  environment.etc = {
    "manifests/longhorn.yaml" = {
      mode = "0644";
      text = lib.readFile ./longhorn.yaml;
    };
  };
  # system.activationScripts = {
  #   "longhorn.yaml".text = ''
  #     ln -sf /etc/manifests/longhorn.yaml /var/lib/rancher/rke2/server/manifests/longhorn.yaml
  #   '';
  # };
}
