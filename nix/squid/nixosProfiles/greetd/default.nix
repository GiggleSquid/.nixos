{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs;
in {
  services = {
    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${nixpkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks -r --cmd Hyprland";
          user = "greeter";
        };
      };
    };
  };
}
