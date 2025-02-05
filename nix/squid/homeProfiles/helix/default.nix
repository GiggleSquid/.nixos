{
  programs.helix = {
    enable = true;
    defaultEditor = true;
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
        gutters = [
          "diff"
          "diagnostics"
          "line-numbers"
          "spacer"
        ];
        statusline = {
          left = [
            "mode"
            "selections"
            "spinner"
            "file-name"
            "file-modification-indicator"
            "version-control"
          ];
          center = [ ];
          right = [
            "diagnostics"
            "file-encoding"
            "file-line-ending"
            "file-type"
            "position"
            "separator"
            "total-line-numbers"
          ];
          mode = {
            normal = "NORMAL";
            insert = "INSERT";
            select = "SELECT";
          };
        };
        lsp = {
          auto-signature-help = false;
          display-messages = true;
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
          scope = "source.nix";
          injection-regex = "nix";
          file-types = [ "nix" ];
          shebangs = [ ];
          comment-token = "#";
          language-servers = [ "nixd" ];
          indent = {
            tab-width = 2;
            unit = "  ";
          };
          auto-format = true;
          formatter = {
            command = "nixfmt";
          };
        }
      ];
      language-server = {
        nixd = {
          command = "nixd";
        };

        rust-analyzer = {
          config.check = {
            command = "clippy";
          };
        };

        yaml-language-server = {
          command = "yaml-language-server";
          args = [ "--stdio" ];
          yaml = {
            format.enable = true;
            validate = true;
            hover = true;
            completion = true;
            schemaStore.enable = true;
            # schemas = { };
          };
        };
      };
    };
  };
}
