local M = {}

function M.apply(config)
    -- 窗口装饰样式
    config.window_decorations = "RESIZE"

    -- 窗口行为
    config.adjust_window_size_when_changing_font_size = false
    config.window_close_confirmation = "NeverPrompt"
    config.initial_cols = 120
    config.initial_rows = 40

    -- 窗口边框
    config.window_frame = {
        border_left_width = '0.1cell',
        border_right_width = '0.1cell',
        border_bottom_height = '0.1cell',
        border_top_height = '0.1cell',
        border_left_color = 'purple',
        border_right_color = 'purple',
        border_bottom_color = 'purple',
        border_top_color = 'purple',
    }
end

return M
