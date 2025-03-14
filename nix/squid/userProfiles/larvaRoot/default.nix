{
  users = {
    mutableUsers = false;
    users.root = {
      hashedPassword = "$6$1tUT.A8U0sTYGu6W$3SbRbdoBS2o.uIqHbjWeZs66WpFHl.AdqkUGpHXGQn5c1tWhS.hZoN/d0hnt.cPuo/FhsUpJQwQLzHHlPGf3k/";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICVJziSSFN+N2kH0EE39oxut9PMWyKJ4Jf0F8axkZe9e"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN6ycNhEFVP15KHUowD7aqlmhryYjTE+BSSbseJsKG1c"
      ];
    };
  };
}
