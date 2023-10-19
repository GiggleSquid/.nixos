{
  programs.git = {
    enable = true;
    userName = "GiggleSquid";
    userEmail = "jack.connors@protonmail.com";

    signing = {
      key = "36348FDE8229C1D2";
      signByDefault = true;
    };

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      core = {
        editor = "hx";
      };
    };
  };
}
