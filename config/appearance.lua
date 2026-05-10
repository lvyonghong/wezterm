local gpu_adapters = require('utils.gpu-adapter')
local backdrops = require('utils.backdrops')
local colors = require('colors.custom')

---@type Config
return {
    -- iMac 2020 是 60Hz 面板，>60 fps 渲染纯属浪费
    max_fps = 60,
    front_end = 'WebGpu', ---@type 'WebGpu' | 'OpenGL' | 'Software'
    webgpu_power_preference = 'HighPerformance',
    webgpu_preferred_adapter = gpu_adapters:pick_best(),
    underline_thickness = '1.5pt',

    -- cursor
    animation_fps = 60,
    cursor_blink_ease_in = 'EaseOut',
    cursor_blink_ease_out = 'EaseOut',
    default_cursor_style = 'BlinkingBar',
    cursor_blink_rate = 650,

    -- 静止闪烁文本（CSI 5 / CSI 6 SGR），减少视觉干扰
    text_blink_rate = 0,
    text_blink_rate_rapid = 0,

    -- color scheme
    colors = colors,

    -- background: pass in `true` if you want wezterm to start with focus mode on (no bg images)
    background = backdrops:initial_options({ no_img = false }),

    -- scrollbar
    enable_scroll_bar = true,

    -- tab bar
    enable_tab_bar = true,
    hide_tab_bar_if_only_one_tab = false,
    use_fancy_tab_bar = false,
    tab_max_width = 32,
    show_tab_index_in_tab_bar = false,
    switch_to_last_active_tab_when_closing_tab = true,

    -- command palette
    command_palette_fg_color = '#b4befe',
    command_palette_bg_color = '#11111b',
    command_palette_font_size = 12,
    command_palette_rows = 25,

    -- window
    window_padding = {
        left = '0.5cell',
        right = '0.5cell',
        top = '0.5cell',
        bottom = '0.5cell',
    },
    adjust_window_size_when_changing_font_size = false,
    window_close_confirmation = 'NeverPrompt',
    window_decorations = 'RESIZE',
    -- macOS 原生窗口背景毛玻璃，0~100，30 比较温和
    macos_window_background_blur = 30,
    visual_bell = {
        fade_in_function = 'EaseIn',
        fade_in_duration_ms = 100,
        fade_out_function = 'EaseOut',
        fade_out_duration_ms = 100,
        target = 'CursorColor',
    },
}
