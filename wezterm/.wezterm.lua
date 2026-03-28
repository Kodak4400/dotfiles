local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.automatically_reload_config = true
config.font_size = 12.0
config.use_ime = true
config.window_background_opacity = 0.75
config.macos_window_background_blur = 20
config.keys = {
    {
        mods = "CMD",
        key = "d",
        action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },
}

return config
