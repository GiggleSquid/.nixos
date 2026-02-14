{ inputs }:
let
  inherit (inputs) nixpkgs;
  lib = nixpkgs.lib;
in
{
  nix = {
    package = nixpkgs.nixVersions.latest;
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
      substituters = [
        "https://nix-cache.lan.gigglesquid.tech"
        "https://local.nix-cache.lan.gigglesquid.tech/attic"
      ];
      trusted-public-keys = [
        "nix-cache.lan.gigglesquid.tech:sQW0gKIG9hooFPBoFDoiDbToJXPhFWpTI4NqNY1MYaA="
        "attic:4reipGK1ubbnLAmGWWtjD2bpuqSWTEsaYuREMEcz7Ro="
      ];
      experimental-features = "nix-command flakes";
    };
    registry.nixpkgs.flake = nixpkgs;
  };

  zramSwap = {
    enable = lib.mkDefault true;
    memoryPercent = lib.mkDefault 50;
    priority = 5;
  };

  services = {
    udisks2 = {
      enable = true;
    };
    xserver.xkb = {
      layout = "gb";
    };
  };

  environment.systemPackages = with nixpkgs; [
    jq
    git
    direnv
    ripgrep
    curl
    wget
  ];

  programs = {
    bash = {
      interactiveShellInit = ''
        if [[ $(${nixpkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} ]]
        then
          shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
          exec ${nixpkgs.fish}/bin/fish $LOGIN_OPTION
        fi
      '';
    };
    fish = {
      enable = true;
    };
  };

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
    useXkbConfig = true;
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
