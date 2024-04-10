{ inputs, cell }:
let
  inherit (cell) rke2Profiles rke2Manifests;
in
with rke2Manifests;
rec {
  base = [ rke2Profiles.common ];

  serverBase = base ++ [ kube-vip ];

  serverInit = serverBase ++ [ rke2Profiles.serverInit ];

  server = serverBase ++ [ rke2Profiles.server ];

  longhorn = base ++ [ rke2Profiles.longhorn ];

  agent = base ++ [ rke2Profiles.agent ];
}
