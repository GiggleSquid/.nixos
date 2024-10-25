{ inputs, cell }:
let
  inherit (inputs) nixpkgs;
in
{
  environment.systemPackages = with nixpkgs; [
    easyeffects
    qpwgraph
  ];

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    # jack.enable = true;
    extraConfig = {
      pipewire = {
        "92-latency" = {
          context.properties = {
            default.clock = {
              rate = 48000;
              allowed-rates = [
                44100
                48000
                96000
                192000
              ];
              quantum = 1024;
              min-quantum = 512;
              max-quantum = 1024;
            };
          };
        };
      };
    };
  };
}
