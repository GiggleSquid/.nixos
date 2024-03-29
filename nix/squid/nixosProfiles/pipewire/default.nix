{
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    # jack.enable = true;
    extraConfig.pipewire."92-latency" = {
      context.properties = {
        default.clock = {
          rate = 48000;
          allowed-rates = [
            44100
            48000
            96000
            192000
          ];
          quantum = 4098;
          min-quantum = 1024;
          max-quantum = 6144;
        };
      };
    };
  };
}
