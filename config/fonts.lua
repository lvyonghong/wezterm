local wezterm = require('wezterm')

---@type Config
return {
    font = wezterm.font_with_fallback {
        { family = 'JetBrainsMono Nerd Font Mono' },
        { family = 'JetBrainsMono Nerd Font' },
        -- 简体中文：避免系统回退挑到繁体/日文字形（CJK 统一码字形差异）
        { family = 'PingFang SC' },
        { family = 'Hiragino Sans GB' },
        'Noto Color Emoji',
    },
    font_size = 13.5,
    line_height = 1.3,
    allow_square_glyphs_to_overflow_width = "WhenFollowedBySpace",

    --ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
    freetype_load_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
    freetype_render_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
}
