{ config }:
{
  programs = {
    gh = {
      enable = true;
      settings = {
        editor = "hx";
      };
    };

    git = {
      enable = true;
      settings = {
        user = {
          email = "jack.connors@protonmail.com";
          name = "GiggleSquid";
        };
        core = {
          editor = "hx";
        };
        init = {
          defaultBranch = "main";
        };
        gpg = {
          format = "ssh";
          ssh = {
            allowedSignersFile = "${config.home.homeDirectory}/.config/git/allowed_signers";
          };
        };
      };

      signing = {
        signByDefault = true;
        format = "ssh";
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJuSKLhdONlRgnIeGcAbUUT+kZlIOOhJKs3jW/CUxYLT jack.connors@protonmail.com | signing";
      };
    };

    git-worktree-switcher = {
      enable = true;
      enableFishIntegration = true;
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
