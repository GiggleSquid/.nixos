{ inputs, config }:
let
  inherit (inputs) nixpkgs;
in
{
  systemd.services.rke2-server = {
    description = "Rancher Kubernetes Engine v2 (server)";
    documentation = [ "https://github.com/rancher/rke2#readme" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    conflicts = [ "rke2-agent.service" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      HOME = "/root";
    };
    preStart = ''
      ${nixpkgs.bash}/bin/sh -xc '! ${nixpkgs.systemd}/bin/systemctl is-enabled --quiet nm-cloud-setup.service' -${nixpkgs.kmod}/bin/modprobe br_netfilter -${nixpkgs.kmod}/bin/modprobe overlay
    '';
    postStop = ''
      -${nixpkgs.bash}/bin/sh -c "systemd-cgls /system.slice/%n  | grep -Eo '[0-9]+ (containerd|kubelet)' | awk '{print $1}' | xargs -r kill"
    '';
    script = ''
      ${nixpkgs.rke2}/bin/rke2 server \
      --tls-san "10.10.4.30,consortium.cephalonetes.lan.gigglesquid.tech" \
      --node-taint "CriticalAddonsOnly=true:NoExecute" \
      --disable "rke2-ingress-nginx" \
      --disable-cloud-controller \
    '';
    serviceConfig = {
      Type = "notify";
      KillMode = "process";
      Delegate = "yes";
      LimitNOFILE = "1048576";
      LimitNPROC = "infinity";
      LimitCORE = "infinity";
      TasksMax = "infinity";
      TimeoutStartSec = 0;
      Restart = "always";
      RestartSec = "5s";
      Environment = [ "PATH=/run/wrappers/bin/:$PATH" ];
    };
  };
}
