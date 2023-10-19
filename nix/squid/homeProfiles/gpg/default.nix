{
  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    sshKeys = [
      "170D1D156DB3E8D8D3601FE3AA07C74EC392F8AD"
    ];
  };
}
