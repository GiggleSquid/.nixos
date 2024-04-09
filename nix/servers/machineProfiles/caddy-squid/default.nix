{ inputs, config }:
let
  inherit (inputs) self nixpkgs;
in
{
  boot.kernel.sysctl = {
    "net.core.rmem_max" = 2500000;
    "net.core.wmem_max" = 2500000;
  };
}
