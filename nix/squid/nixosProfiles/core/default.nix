{ inputs }:
let
  inherit (inputs) nixpkgs;
in
{
  nix = {
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 3d";
    };
    settings = {
      auto-optimise-store = true;
      allowed-users = [ "@wheel" ];
      trusted-users = [
        "root"
        "@wheel"
      ];
      experimental-features = "nix-command flakes";
    };
    registry.nixpkgs.flake = nixpkgs;
  };

  zramSwap = {
    enable = true;
    priority = 5;
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
    udisks2 = {
      enable = true;
    };
  };

  environment.systemPackages = with nixpkgs; [
    jq
    git
    direnv
    ripgrep
    unzip
    curl
    wget
    ventoy
    kdiskmark
  ];

  i18n =
    let
      defaultLocale = "en_GB.UTF-8";
    in
    {
      inherit defaultLocale;
      extraLocaleSettings = {
        LC_ADDRESS = defaultLocale;
        LC_IDENTIFICATION = defaultLocale;
        LC_MEASUREMENT = defaultLocale;
        LC_MONETARY = defaultLocale;
        LC_NAME = defaultLocale;
        LC_NUMERIC = defaultLocale;
        LC_PAPER = defaultLocale;
        LC_TELEPHONE = defaultLocale;
        LC_TIME = defaultLocale;
      };
    };

  console = {
    earlySetup = true;
    keyMap = "uk";
    colors = [
      "1e1e2e"
      "181825"
      "313244"
      "45475a"
      "585b70"
      "cdd6f4"
      "f5e0dc"
      "b4befe"
      "f38ba8"
      "fab387"
      "f9e2af"
      "a6e3a1"
      "94e2d5"
      "89b4fa"
      "cba6f7"
      "f2cdcd"
    ];
  };
}
