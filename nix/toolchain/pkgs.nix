{ inputs, cell }:
inputs.nixpkgs.appendOverlays [
  (_: _: cell.overlays)
  inputs.rust-overlay.overlays.default
]
