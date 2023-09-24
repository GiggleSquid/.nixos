{...}: {
  programs = {
    gpg.enable = true;

    lsd = {
      enable = true;
      enableAliases = true;
      settings = {
        total-size = true;
      };
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryFlavor = "qt";
      sshKeys = ["170D1D156DB3E8D8D3601FE3AA07C74EC392F8AD"];
    };
  };
}
