local gpu_adapters = require('utils.gpu-adapter')
local backdrops = require('utils.backdrops')
local colors = require('colors.custom')

---@type Config
return {
    -- iMac 2020 是 60Hz 面板，>60 fps 渲染纯属浪费
    max_fps = 60,
    -- 使用 WezTerm 内置 block 字形，避免 CJK 字体下框线绘图断裂
    custom_block_glyphs = true,
    front_end = 'WebGpu', ---@type 'WebGpu' | 'OpenGL' | 'Software'
    webgpu_power_preference = 'HighPerformance',
    webgpu_preferred_adapter = gpu_adapters:pick_best(),
    underline_thickness = '1.5pt',

    -- cursor
    animation_fps = 60,
    cursor_blink_ease_in = 'EaseInOut',
    cursor_blink_ease_out = 'EaseInOut',
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
    hide_tab_bar_if_only_one_tab = true,
    use_fancy_tab_bar = false,
    tab_bar_at_bottom = true,
    tab_max_width = 40,
    show_tab_index_in_tab_bar = false,
    switch_to_last_active_tab_when_closing_tab = true,

    -- command palette
    command_palette_fg_color = '#b4befe',
    command_palette_bg_color = '#11111b',
    command_palette_font_size = 12,
    command_palette_rows = 25,

    -- window
    window_frame = {
        active_titlebar_bg = '#11111b',
        inactive_titlebar_bg = '#11111b',
        border_left_width = '0.5pt',
        border_right_width = '0.5pt',
        border_bottom_height = '0.5pt',
    },
    window_padding = {
        left = '1cell',
        right = '1cell',
        top = '0.5cell',
        bottom = '0.5cell',
    },
    adjust_window_size_when_changing_font_size = false,
    -- vim/less 等备选缓冲区中滚轮每格滚动行数
    alternate_buffer_wheel_scroll_speed = 3,
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

    inactive_pane_hsb = {
        hue = 1.0,
        saturation = 0.9,
        brightness = 0.7,
    },

    pane_focus_follows_mouse = true,
}
