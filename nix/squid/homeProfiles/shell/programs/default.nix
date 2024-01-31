{inputs}: let
  inherit (inputs) nixpkgs;
in {
  fish = {
    enable = true;
    interactiveShellInit = ''
    '';
    functions = {
      starship_transient_rprompt_func = ''
        starship module time
      '';
    };
  };

  k9s = {
    enable = true;
  };

  zoxide = {
    enable = true;
    options = [
      "--cmd cd"
    ];
  };

  bat = {
    enable = true;
    config = {
      theme = "catppuccin-mocha";
    };
    themes = {
      catppuccin-mocha = {
        src = nixpkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "bat";
          rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
          sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
        };
        file = "Catppuccin-mocha.tmTheme";
      };
    };
  };

  lsd = {
    enable = true;
    enableAliases = true;
    settings = {
      total-size = true;
    };
  };

  bash = {
    enable = true;
  };
}
