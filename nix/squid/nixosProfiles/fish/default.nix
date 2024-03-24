{ inputs }:
{
  environment.systemPackages = with inputs.nixpkgs; [
    fishPlugins.sponge
    fishPlugins.fzf-fish
    fishPlugins.colored-man-pages
    fzf
    fd
    bat
  ];
  programs.fish.enable = true;
}
