{
  inputs,
  cell,
}: {
  imports = [inputs.sops-nix.nixosModules.sops];

  sops.defaultSopsFile = ././../secrets/secrets.yaml;
}
