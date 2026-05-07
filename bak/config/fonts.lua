local wezterm = require("wezterm")

local M = {}

function M.apply(config)
    -- config.font = wezterm.font "JetBrainsMono Nerd Font Mono"
    -- config.font_size = 13
    config.font = wezterm.font_with_fallback {
        { family = 'JetBrainsMono Nerd Font Mono', weight = 'DemiBold', scale = 1.0 },
        { family = 'JetBrains Mono',               weight = 'DemiBold' }
    }
    config.font_size = 13 or 14
end

return M
