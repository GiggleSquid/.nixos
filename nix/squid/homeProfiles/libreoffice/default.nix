{
  inputs,
  cell,
}:
let
  inherit (inputs) nixpkgs home-manager;

  catppuccinLibreOffice = nixpkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "libreoffice";
    rev = "f6120a5c90777a1558f6c2f5f2e29ef11c335769";
    hash = "sha256-VnQO6113GKCM2C2r/4MV7AK8DBTAWm06zdSwCTYLINQ=";
  };

  catppuccinLibreOfficeInstallScript = (
    nixpkgs.writers.writeBashBin "catppuccin-libreoffice-install" ''
      echo "Installation for $1"
      echo "Copying palette to config directory ..."
      if [ "$(uname)" = "Linux" ]; then
        # Must change hardcoded path. Can't figure it out on this context though
        fname=/home/squid/.config/libreoffice/4/user/registrymodifications.xcu
        fname="$(realpath $fname)" # expand
      else
        echo "Unsupported operating system. Aborting ..."
        exit 1
      fi

      # Create backup of LibreOffice registry before modifications
      cp -i "$fname" registrymodifications.xcu.$(date -u +"%Y-%m-%dT%H:%M:%SZ")bak

      # Check settings file
      if ! [ -f "$fname" ]; then
        echo "Settings file doesn't exist in expected location. Aborting ..."
        exit 1
      elif ! tail -n1 "$fname" | grep -E -q '^</oor:items>$'; then
        echo "Settings file doesn't match expected format. Aborting ..."
        exit 1
      fi

      # Insert theme between last two lines if not present
      new_settings="$(head -n $(($(wc < "$fname" -l) - 1)) "$fname" && cat $1 && tail -n1 "$fname")"

      # Write new settings to settings file
      echo "$new_settings" > "$fname"
    ''
  );
in
{
  home = {
    packages = with inputs.nixpkgs; [
      libreoffice-qt6-fresh
      hunspell
      hunspellDicts.en_GB-ise
    ];
    activation = {
      installCatppuccinLibreOfficeTheme =
        home-manager.lib.hm.dag.entryAfter
          [
            "writeBoundary"
            "installPackages"
          ]
          ''
            ${catppuccinLibreOfficeInstallScript}/bin/catppuccin-libreoffice-install ${
              catppuccinLibreOffice + "/themes/mocha/peach/catppuccin-mocha-peach.xcu"
            }
          '';
    };
  };

  # https://wiki.documentfoundation.org/UserProfile
  xdg = {
    configFile = {
      "libreoffice/4/user/config/catppuccin-mocha-peach.soc" = {
        source = catppuccinLibreOffice + "/themes/mocha/peach/catppuccin-mocha-peach.soc";
      };
    };
  };
}
