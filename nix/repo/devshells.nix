{ inputs, cell }:
let
  inherit (inputs)
    nixpkgs
    hive
    std
    colmena
    ;
  inherit (nixpkgs) lib;
  inherit (hive.bootstrap.shell) bootstrap;
  inherit (std.lib) dev;
in
lib.mapAttrs (_: dev.mkShell) {
  default = {
    name = "Hive";

    imports = [ bootstrap ];

    commands =
      let
        mkCategory = category: attrset: attrset // { inherit category; };
        hexagon = mkCategory "hexagon";
        nix = mkCategory "nix";
      in
      lib.concatLists [
        (builtins.map hexagon [
          { package = colmena.packages.colmena; }
          { package = nixpkgs.sops; }
          { package = nixpkgs.ssh-to-age; }
          { package = nixpkgs.transcrypt; }
          { package = nixpkgs.openssl; }
          {
            name = "larva";
            help = "Write a minimal proxmox lxc image to disk";
            command = ''
              nixos-generate --flake $PRJ_ROOT#larva -f proxmox-lxc $@
            '';
          }
          {
            name = "pupae";
            help = "Write a minimal proxmox vm image to disk";
            command = ''
              nixos-generate --flake $PRJ_ROOT#pupae -f proxmox $@
            '';
          }
          {
            name = "nymph4";
            help = "Write a minimal rpi4 sd image to disk";
            command = ''
              nixos-generate --flake $PRJ_ROOT#nymph4 -f sd-aarch64 --system aarch64-linux $@
            '';
          }
          {
            name = "get-age";
            help = "Convert ssh ed25519 pub key (from ssh-keyscan) to age";
            command = ''
              read -p "Remote machine IP/domain: " remote
              ssh-keyscan -qt ed25519 $remote | ssh-to-age $@
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
            name = "vm";
            help = "Test configuration in a VM";
            command = "sudo nixos-rebuild build-vm --flake $PRJ_ROOT $@";
          }
          {
            name = "test";
            help = "Test configuration";
            command = "sudo nixos-rebuild test --flake $PRJ_ROOT $@";
          }
          {
            name = "update";
            help = "Update flake";
            command = "sudo nix-channel --update && nix flake update --flake $PRJ_ROOT $@";
          }
          {
            name = "check";
            help = "Check flake";
            command = "nix flake check $PRJ_ROOT $@";
          }
          {
            name = "gc";
            help = "Garbage collection";
            command = "sudo nix store gc -v $@";
          }
        ])
      ];
  };
}
