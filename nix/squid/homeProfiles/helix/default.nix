{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  programs.helix = {
    enable = true;
    defaultEditor = true;
    extraPackages = with nixpkgs; [
      nixd
      nixfmt-rfc-style
      nodePackages.prettier
      prettier-plugin-go-template
      vscode-langservers-extracted
      superhtml
      go
      gopls
      delve
      gotools
      golangci-lint-langserver
      marksman
      taplo
      lua-language-server
      yaml-language-server
      bash-language-server
      caddy
    ];
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
        {
          name = "gotmpl";
          file-types = [ { glob = "*.go.html"; } ];
          block-comment-tokens = {
            start = "<!--";
            end = "-->";
          };
          language-servers = [
            "gopls"
            "vscode-html-language-server"
          ];
          auto-format = true;
          formatter = {
            command = "prettier";
            args = [
              "--plugin"
              "${nixpkgs.prettier-plugin-go-template}/lib/node_modules/prettier-plugin-go-template/lib/index.js"
              "--parser"
              "go-template"
              "--bracket-same-line"
            ];
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

  xdg = {
    configFile = {
      "helix/runtime/queries/gotmpl/injections.scm" = {
        text = ''
          ((text) @injection.content
           (#set! injection.language "html")
           (#set! injection.combined))
        '';
      };
    };
  };
}
