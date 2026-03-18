{
  programs.wezterm = {
    enable = true;
    extraConfig = # lua
      ''
        local config = {}
        if wezterm.config_builder then
          config = wezterm.config_builder()
        end

        local gpus = wezterm.gui.enumerate_gpus()

        config = {
          color_scheme = 'Catppuccin Mocha',
          hide_tab_bar_if_only_one_tab = true,
          font = wezterm.font 'Iosevka Term SS14',
          font_size = 12,
          front_end = 'WebGpu',
          window_decorations = 'TITLE | RESIZE',
          enable_wayland =  true,
          webgpu_preferred_adapter = {
            backend = 'Vulkan',
            device_type = 'DiscreteGpu',
            name = 'AMD Radeon RX 7800 XT (RADV NAVI32)',
          },

          keys = {
           {
              key = 'Enter',
              mods = 'ALT',
              action = wezterm.action.DisableDefaultAssignment,
            },
          },
        }
        return config
      '';
  };
}
