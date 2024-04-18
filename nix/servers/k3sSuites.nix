{ inputs, cell }:
let
  inherit (cell) k3sProfiles;
in
with k3sProfiles;
rec {
  base = [ common ];

  serverInit-suite = base ++ [ serverInit ];

  server-suite = base ++ [ server ];

  agent-suite = base ++ [ agent ];
}
