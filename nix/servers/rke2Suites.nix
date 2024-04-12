{ inputs, cell }:
let
  inherit (cell) rke2Profiles;
in
with rke2Profiles;
rec {
  base = [ common ];

  serverInit-suite = base ++ [ serverInit ];

  server-suite = base ++ [ server ];

  agent-suite = base ++ [ agent ];
}
