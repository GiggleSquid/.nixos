{...}: {
  xdg.configFile."hypr/hyprpaper.conf".source = builtins.toFile "hyprpaper.conf" ''
    preload = ~/nixos/home/rice/hyprpaper/wallpapers/Tarantula_Nebula_JWST_x_Chandra_X-ray_observatory_composite.jpg
    wallpaper = ,~/nixos/home/rice/hyprpaper/wallpapers/Tarantula_Nebula_JWST_x_Chandra_X-ray_observatory_composite.jpg
  '';
}
