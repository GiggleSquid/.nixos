{ inputs, cell }:
inputs.nixpkgs.appendOverlays [
  (_: _: cell.overlays)
  inputs.rust-overlay.overlays.default
  inputs.nix-minecraft.overlay
  inputs.nur.overlays.default
  inputs.nix-topology.overlays.default
]
