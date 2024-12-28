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
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.allowed-rates" = [
              44100
              48000
              96000
              192000
            ];
            "default.clock.quantum" = 256;
            "default.clock.min-quantum" = 256;
            "default.clock.max-quantum" = 256;
          };
        };
      };
      pipewire-pulse."92-low-latency" = {
        "context.properties" = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = { };
          }
        ];
        "pulse.properties" = {
          "pulse.min.req" = "256/48000";
          "pulse.default.req" = "256/48000";
          "pulse.max.req" = "256/48000";
          "pulse.min.quantum" = "256/48000";
          "pulse.max.quantum" = "256/48000";
        };
        "stream.properties" = {
          "node.latency" = "256/48000";
          "resample.quality" = 1;
        };
      };
    };
  };
}
