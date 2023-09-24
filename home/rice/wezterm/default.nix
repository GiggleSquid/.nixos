{...}: {
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = {}
      -- In newer versions of wezterm, use the config_builder which will
      -- help provide clearer error messages
      if wezterm.config_builder then
        config = wezterm.config_builder()
      end
      config = {
        color_scheme = 'Catppuccin Mocha',
        hide_tab_bar_if_only_one_tab = true,
        font = wezterm.font 'JetBrainsMono Nerd Font',
        font_size = 13,
        front_end = 'WebGpu',
        window_decorations = 'RESIZE',
        enable_wayland =  false,
      }
      return config
    '';
  };
}
