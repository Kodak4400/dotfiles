local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.automatically_reload_config = true
config.initial_cols = 200
config.initial_rows = 50
config.font_size = 14.0
config.use_ime = true
-- config.color_scheme = 'Tokyo Night Light (Gogh)'
config.window_background_opacity = 0.75
config.text_background_opacity = 0.5
config.macos_window_background_blur = 20
config.keys = {
    {
        mods = "CMD",
        key = "d",
        action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
    },
    {
        mods = "CTRL",
        key = "PageDown",
        action = wezterm.action.ActivateTabRelative(1),
    },
    {
        mods = "CTRL",
        key = "PageUp",
        action = wezterm.action.ActivateTabRelative(-1),
    },
}

-- アクティブタブを見やすくカラーリング
config.colors = {
    tab_bar = {
        background = '#0a0a0a',
        active_tab = {
            bg_color = '#00b4d8',  -- 明るいシアンブルー
            fg_color = '#000000',
            intensity = 'Bold',
        },
        inactive_tab = {
            bg_color = '#1e1e2e',
            fg_color = '#6c7086',
        },
        inactive_tab_hover = {
            bg_color = '#313244',
            fg_color = '#cdd6f4',
        },
        new_tab = {
            bg_color = '#1e1e2e',
            fg_color = '#6c7086',
        },
        new_tab_hover = {
            bg_color = '#313244',
            fg_color = '#cdd6f4',
        },
    },
}

return config
