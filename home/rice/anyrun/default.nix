{
  inputs,
  pkgs,
  ...
}: {
  programs.anyrun = {
    enable = true;
    config = {
      plugins = with inputs.anyrun.packages.${pkgs.system}; [
        applications
        dictionary
        kidex
        rink
        shell
        stdin
      ];

      y.absolute = 50;
      #hidePluginInfo = true;
      closeOnClick = true;
    };

    extraCss = ''
       * {
        transition: 200ms ease-out;
        color: #cdd6f4;
        font-family: JetBrainsMono Nerd Font;
        font-size: 1.1rem;
      }

      #window,
      #match,
      #entry,
      #plugin,
      #main {
        background: transparent;
      }

      #match:selected {
        background: rgba(203, 166, 247, 0.8);
      }

      #match {
        padding: 3px;
        border-radius: 16px;
      }

      #entry {
        border-radius: 16px;
      }

      box#main {
        background: rgba(30, 30, 46, 0.8);
        border: 1px solid #28283d;
        border-radius: 24px;
        padding: 8px;
      }

      row:first-child {
        margin-top: 6px;
      }
    '';
  };
}
