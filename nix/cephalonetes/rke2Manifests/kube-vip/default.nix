{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs kubenix;
  lib = nixpkgs.lib // builtins;
in {
  environment.etc = {
    "test.yaml" = {
      source =
        (kubenix.evalModules.x86_64-linux {
          module = {kubenix, ...}: {
            imports = [kubenix.modules.k8s];
            kubernetes.resources.pods.example.spec.containers.example.image = "nginx";
          };
        })
        .config
        .kubernetes
        .resultYAML;
    };

    "manifests/kube-vip-rbac.yaml" = {
      mode = "0644";
      source =
        nixpkgs.fetchurl
        {
          url = "https://kube-vip.io/manifests/rbac.yaml";
          hash = "sha256-B6018KsDpuhPq4PjJxGHszmvzuQuqnPd9e2AoNH21tg=";
        };
    };

    "manifests/kube-vip-ds.yaml" = {
      mode = "0644";
      text = lib.readFile ./kube-vip-ds.yaml;
    };
  };

  system.activationScripts = {
    "kube-vip-rbac.yaml".text = ''
      ln -sf /etc/manifests/kube-vip-rbac.yaml /var/lib/rancher/rke2/server/manifests/kube-vip-rbac.yaml
    '';

    "kube-vip-ds.yaml".text = ''
      ln -sf /etc/manifests/kube-vip-ds.yaml /var/lib/rancher/rke2/server/manifests/kube-vip-ds.yaml
    '';
  };
}
