{ inputs }:
let
  inherit (inputs) nixpkgs;
in
{
  fish = {
    enable = true;
    interactiveShellInit = '''';
    functions = {
      starship_transient_rprompt_func = ''
        starship module time
      '';
    };
  };

  zoxide = {
    enable = true;
    options = [ "--cmd cd" ];
  };

  bat = {
    enable = true;
    config = {
      theme = "Catppuccin-mocha";
    };
  };

  btop = {
    enable = true;
    settings = { };
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
