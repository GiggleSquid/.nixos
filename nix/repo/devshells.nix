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

      commands = let
        mkCategory = category: attrset: attrset // {inherit category;};
        hexagon = mkCategory "hexagon";
        nix = mkCategory "nix";
      in
        lib.concatLists [
          (builtins.map hexagon [
            {package = colmena.packages.colmena;}
            {package = nixpkgs.sops;}
            {
              name = "larva";
              help = "Write a minimal proxmox vm image to disk";
              command = ''
                nixos-generate --flake "$PRJ_ROOT"#larva -f proxmox $@
              '';
            }
          ])
          (builtins.map nix [
            {
              name = "sw";
              help = "Switch configurations";
              command = "sudo nixos-rebuild switch --upgrade --flake $PRJ_ROOT $@";
            }
            {
              name = "boot";
              help = "Switch boot configuration";
              command = "sudo nixos-rebuild boot --upgrade --flake $PRJ_ROOT $@";
            }
            {
              name = "test";
              help = "Test configuration";
              command = "sudo nixos-rebuild test --flake $PRJ_ROOT $@";
            }
            {
              name = "update";
              help = "Update inputs";
              command = "sudo nix-channel --update && nix flake update $PRJ_ROOT $@";
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
