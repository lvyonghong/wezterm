local wezterm = require('wezterm')
local platform = require('utils.platform')

---@type Config
return {
    font = wezterm.font_with_fallback {
        { family = 'JetBrainsMono Nerd Font Mono' },
        { family = 'JetBrainsMono Nerd Font' },
        'Noto Color Emoji',
    },
    font_size = platform.is_mac and 13.5 or 14,
    line_height = 1.3,
    allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace",

    --ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
    freetype_load_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
    freetype_render_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
}
