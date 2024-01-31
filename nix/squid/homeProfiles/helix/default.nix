{
  programs.helix = {
    enable = true;
    settings = {
      theme = "catppuccin_mocha";
      editor = {
        color-modes = true;
        true-color = true;
        bufferline = "always";
        cursorline = true;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "block";
        };
        indent-guides = {
          render = true;
          character = "┊";
        };
        gutters = ["diff" "diagnostics" "line-numbers" "spacer"];
        statusline = {
          left = ["mode" "selections" "spinner" "file-name" "file-modification-indicator" "version-control"];
          center = [];
          right = ["diagnostics" "file-encoding" "file-line-ending" "file-type" "position" "separator" "total-line-numbers"];
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };
        lsp = {
          display-inlay-hints = true;
        };
        whitespace = {
          render = "all";
          characters = {
            space = "·";
            nbsp = "⍽";
            tab = "";
            newline = "";
          };
        };
        soft-wrap = {
          enable = true;
        };
      };
    };
    languages = {
      language = [
        {
          name = "nix";
          auto-format = true;
          formatter = {
            command = "alejandra";
            args = ["-q"];
          };
        }
      ];
      language-server = {
        rust-analyzer = {
          config.check = {
            command = "clippy";
          };
        };
        yaml-language-server = {
          config.yaml = {
            format.enable = true;
            validate = true;
            hover = true;
            completion = true;
            schemaStore.enable = true;
            # schemas = {

            # };
          };
        };
      };
    };
  };
}
