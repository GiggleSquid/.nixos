{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  boost,
  libtorrent-rasterbar,
  openssl,
  qt6,
  zlib,

  guiSupport ? true,
  dbus,

  trackerSearch ? true,
  python3,

  webuiSupport ? true,
}:

stdenv.mkDerivation rec {
  pname = "qbittorrent-enhanced" + lib.optionalString (!guiSupport) "-nox";
  version = "5.0.0.10";

  src = fetchFromGitHub {
    owner = "c0re100";
    repo = "qBittorrent-Enhanced-Edition";
    rev = "release-${version}";
    hash = "sha256-MQo5z0OKwCw5kVQKyonrZxhgAvDdevuA+RNNFf1yj10=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs =
    [
      openssl.dev
      boost
      zlib
      libtorrent-rasterbar
      qt6.qtbase
      qt6.qttools
    ]
    ++ lib.optionals guiSupport [
      dbus
    ]
    ++ lib.optionals (guiSupport && stdenv.hostPlatform.isLinux) [
      qt6.qtwayland
    ]
    ++ lib.optionals trackerSearch [
      python3
    ];

  cmakeFlags =
    lib.optionals (!guiSupport) [
      "-DGUI=OFF"
    ]
    ++ lib.optionals (!webuiSupport) [
      "-DWEBUI=OFF"
    ];

  qtWrapperArgs = lib.optionals trackerSearch [
    "--prefix PATH : ${lib.makeBinPath [ python3 ]}"
  ];

  dontWrapGApps = true;

  preFixup = ''
    qtWrapperArgs+=("''${gappsWrapperArgs[@]}")
  '';

  meta = {
    description = "Unofficial enhanced version of qBittorrent, a BitTorrent client";
    homepage = "https://github.com/c0re100/qBittorrent-Enhanced-Edition";
    changelog = "https://github.com/c0re100/qBittorrent-Enhanced-Edition/blob/${src.rev}/Changelog";
    license = with lib.licenses; [
      gpl2Only
      gpl3Only
    ];
    maintainers = with lib.maintainers; [ ByteSudoer ];
    mainProgram = "qBittorrent-enhanced";
    platforms = lib.platforms.linux;
  };
}
