{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
  inherit (nixpkgs) formats;
  toml = formats.toml {};
in {
  xdg.configFile."wpaperd/wallpaper.toml".source = toml.generate "wpaperd-settings" {
    default = {
      path = ./_wallpaper.d/Tarantula_Nebula_JWST_x_Chandra_X-ray_observatory_composite.jpg;
    };
  };
}
