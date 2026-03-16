{
  inputs,
}:
let
  inherit (inputs) nixpkgs;
in
{
  home.file = {
    ".librewolf/d0i5283q.default/chrome" = {
      recursive = true;
      source =
        nixpkgs.fetchFromGitHub {
          owner = "oviung";
          repo = "DownToneUI-Firefox";
          rev = "bfe2592212470c02a9e17467a6594133b1425dfc";
          hash = "sha256-ku7dMLS6yu0NEa9+ZUN35xSIIrdAqvkuYzWK0XeRCwg=";
        }
        + /chrome;
    };
    ".librewolf/d0i5283q.default/chrome/DownToneUI/override_chrome.css" = {
      force = true;
      text = # css
        ''
          * {
            --dtui-sidebar-collapsed-width: 260px;
            --dtui-sidebar-no-extend-width: 260px;
            --dtui-sidebar-extended-width: 260px;
          }
          #context-navigation, #context-sep-navigation, #context-sendimage,
          #context-savelink, #context-savepage, #context-inspect-a11y,
          #context-print-selection, #context-selectall, #context-sep-selectall,
          #toolbar-context-undoCloseTab +menuseparator {
            display: flex !important;
          }
        '';
    };

    ".librewolf/d0i5283q.default/chrome/DownToneUI/override_globals.css" = {
      force = true;
      text = # css
        ''
          * {
            --dtui-theme-color-scheme: dark;
            --dtui-theme-main-color: 30, 30, 46;
            --dtui-theme-secondary-color: 24, 24, 37;
            --dtui-theme-accent-color: 17, 17, 27;
            --dtui-theme-text-color: 205, 214, 244;

            --dtui-theme-accent-low-alpha: 0.5;
            --dtui-theme-accent-mid-alpha: 0.75;
            --dtui-theme-accent-high-contrast: hsl(23deg, 92%, 75%);
            --dtui-theme-text-low-alpha: 0.5;
            --dtui-theme-text-mid-alpha: 0.75;

            --dtui-theme-separator-color: rgba(var(--dtui-theme-text-color), 0.1);
            --dtui-theme-border-color: rgba(var(--dtui-theme-text-color), 0);
            --dtui-theme-border-width: 2px;
            --dtui-theme-border-radius: 6px;

            --dtui-sidebar-hover-debounce: 0ms;
          }
        '';
    };
  };
  programs = {
    librewolf = {
      enable = true;
      settings = {
        "browser.compactmode.show" = true;
        "browser.uidensity" = 2;
        "identity.fxaccounts.enabled" = true;
        "privacy.clearOnShutdown.history" = false;
        "privacy.clearOnShutdown.downloads" = false;
        "middlemouse.paste" = false;
        "general.autoScroll" = true;
        "webgl.disabled" = false;
        "sidebar.revamp" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "widget.gtk.ignore-bogus-leave-notify" = 1;
        "widget.gtk.libadwaita-colors.enabled" = false;
        "widget.windows.mica.popups" = 0;
      };
    };
  };
}
