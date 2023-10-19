{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs hive std colmena;
  inherit (nixpkgs) lib;
  inherit (hive.bootstrap.shell) bootstrap;
  inherit (std.lib) dev;
in
  lib.mapAttrs (_: dev.mkShell) {
    default = {
      name = "Hive";

      imports = [bootstrap];

      packages = with nixpkgs; [
        alejandra
      ];

      commands = let
        mkCategory = category: attrset: attrset // {inherit category;};
        hexagon = mkCategory "hexagon";
        nix = mkCategory "nix";
      in
        lib.concatLists [
          (builtins.map hexagon [
            {package = colmena.packages.colmena;}
          ])
          (builtins.map nix [
            {
              name = "switch";
              help = "Switch configurations";
              command = "sudo nixos-rebuild switch --flake $PRJ_ROOT $@";
            }
            {
              name = "boot";
              help = "Switch boot configuration";
              command = "sudo nixos-rebuild boot --flake $PRJ_ROOT $@";
            }
            {
              name = "test";
              help = "Test configuration";
              command = "sudo nixos-rebuild test --flake $PRJ_ROOT $@";
            }
            {
              name = "update";
              help = "Update inputs";
              command = "nix flake update $PRJ_ROOT $@";
            }
            {
              name = "check";
              help = "Check flake";
              command = "nix flake check $PRJ_ROOT $@";
            }
          ])
        ];
    };
  }
