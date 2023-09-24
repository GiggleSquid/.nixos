{pkgs, ...}: {
  home.packages = with pkgs; [
    rust-bin.stable.latest.default
    rust-analyzer-unwrapped
    gcc
    alejandra
    lldb
    alsa-utils
    bitwarden
    borgbackup
    btop
    libsForQt5.dolphin
    libsForQt5.baloo
    ffmpeg
    filelight
    gimp
    gridcoin-research
    inkscape
    jellyfin-media-player
    jq
    kate
    lutris
    monero-gui
    nfs-utils
    pavucontrol
    helvum
    prismlauncher
    prusa-slicer
    qbittorrent
    rclone
    ripgrep
    unzip
    vintagestory
    vorta
    wget
    dconf
    libreoffice
    zathura
    kubectl
    kubernetes-helm
    k3sup
    libsForQt5.ark
    libsForQt5.okular
    hyprpaper
    colmena
    nil
    vscode-langservers-extracted
    marksman
    taplo
    lua-language-server

    #https://github.com/NixOS/nixpkgs/issues/159267#issuecomment-1037372237
    (writeShellApplication {
      name = "discord";
      text = "${pkgs.discord}/bin/discord --use-gl=desktop";
    })
    (makeDesktopItem {
      name = "discord";
      exec = "discord";
      desktopName = "Discord";
    })

    # Wine and proton shit
    protonup-qt
    protontricks
    mono
    wineWowPackages.stagingFull
    winetricks
  ];
}
