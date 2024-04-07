local wezterm = require 'wezterm'
local config = {}
local gpus = wezterm.gui.enumerate_gpus()
  -- In newer versions of wezterm, use the config_builder which will
  -- help provide clearer error messages
  if wezterm.config_builder then
    config = wezterm.config_builder()
  end
  config = {
    color_scheme = 'Catppuccin Mocha',
    hide_tab_bar_if_only_one_tab = true,
    font = wezterm.font 'Iosevka Term SS14',
    font_size = 12,
    front_end = 'WebGpu',
    window_decorations = 'TITLE | RESIZE',
    enable_wayland =  true,
    webgpu_preferred_adapter = gpus[2],
  }
  config.keys = {
   {
      key = 'Enter',
      mods = 'ALT',
      action = wezterm.action.DisableDefaultAssignment,
    },
  }
  return config

