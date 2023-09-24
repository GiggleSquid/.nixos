{...}: {
  programs.git = {
    enable = true;
    userName = "GiggleSquid";
    userEmail = "jack.connors@protonmail.com";
    signing = {
      key = "D8E9772A8F5D1EE9AD68AB1656C0061922D8203B";
      signByDefault = true;
    };
    extraConfig = {
      init = {defaultBranch = "main";};
      core = {
        editor = "hx";
      };
    };
  };
}
