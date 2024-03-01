{config}: {
  programs = {
    gh = {
      enable = true;
      settings = {
        editor = "hx";
      };
    };

    git = {
      enable = true;
      userName = "GiggleSquid";
      userEmail = "jack.connors@protonmail.com";

      signing = {
        signByDefault = true;
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJuSKLhdONlRgnIeGcAbUUT+kZlIOOhJKs3jW/CUxYLT jack.connors@protonmail.com | signing";
      };

      extraConfig = {
        init = {
          defaultBranch = "main";
        };
        core = {
          editor = "hx";
        };
        gpg = {
          format = "ssh";
          ssh = {
            allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
          };
        };
      };
    };
  };

  xdg = {
    configFile = {
      "git/allowed_signers" = {
        text = "jack.connors@protonmail.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJuSKLhdONlRgnIeGcAbUUT+kZlIOOhJKs3jW/CUxYLT jack.connors@protonmail.com | signing";
      };
    };
  };
}
