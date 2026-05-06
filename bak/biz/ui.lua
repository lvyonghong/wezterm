local wezterm = require 'wezterm'

wezterm.on('update-status', function(window, pane)
    local cells = {}
    local title = pane:get_title()
    local cwd = ''
    local isLocal = string.sub(title, 1, 1)
    if isLocal == '~' then
        local cwd_uri = pane:get_current_working_dir()
        cwd_uri = string.sub(cwd_uri, 8)
        local slash = string.find(cwd_uri, '/')
        if slash then
            cwd = string.sub(cwd_uri, slash)
        end
    else
        local remoteSplit = string.find(title, ':')
        if remoteSplit then
            cwd = string.sub(title, remoteSplit + 1)
        end
    end
    table.insert(cells, cwd)
    -- I like my date/time in this style: "Wed Mar 3 08:14"
    local date = wezterm.strftime '%a %b %-d %H:%M'
    table.insert(cells, date)

    -- An entry for each battery (typically 0 or 1 battery)
    for _, b in ipairs(wezterm.battery_info()) do
        table.insert(cells, string.format('%.0f%%', b.state_of_charge * 100))
    end

    -- The powerline < symbol
    local LEFT_ARROW = utf8.char(0xe0b3)
    -- The filled in variant of the < symbol
    local SOLID_LEFT_ARROW = utf8.char(0xe0b2)

    -- Color palette for the backgrounds of each cell
    local colors = {
        '#3C1361',
        '#52307C',
        '#663A82',
        '#7C5295',
        '#B491C8',
    }
    -- Foreground color for the text across the fade
    local text_fg = '#C0C0C0'
    -- The elements to be formatted
    local elements = {}
    -- How many cells have been formatted
    local num_cells = 0
    -- Translate a cell into elements
    local function push(text, is_last)
        local cell_no = num_cells + 1
        table.insert(elements, { Foreground = { Color = text_fg } })
        table.insert(elements, { Background = { Color = colors[cell_no] } })
        table.insert(elements, { Text = ' ' .. text .. ' ' })
        if not is_last then
            table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
            table.insert(elements, { Text = SOLID_LEFT_ARROW })
        end
        num_cells = num_cells + 1
    end

    while #cells > 0 do
        local cell = table.remove(cells, 1)
        push(cell, #cells == 0)
    end

    window:set_right_status(wezterm.format(elements))
end)

return {
    -- color_schemas
    color_scheme = "OLEDppuccin",
    -- 自定义配色
    colors = {
        cursor_bg = '#C8C093',
        cursor_fg = '#C8C093',
        cursor_border = '#C8C093',
        scrollbar_thumb = '#444444',
        split = '#233222',
    },
    font = wezterm.font_with_fallback {
        { family = 'JetBrainsMono Nerd Font Mono', weight = 'DemiBold', scale = 1.0 },
        { family = 'JetBrains Mono',               weight = 'DemiBold' }
    },
    font_size = 14,
    line_height = 1.2,
    tab_max_width = 36,
    window_decorations = 'INTEGRATED_BUTTONS | RESIZE',
    -- window_decorations = 'MACOS_FORCE_ENABLE_SHADOW',
    window_background_opacity = 0.85,
    text_background_opacity = 0.5,
    tab_bar_at_bottom = false,
    use_fancy_tab_bar = true,
    show_tab_index_in_tab_bar = true,
    show_new_tab_button_in_tab_bar = false,
    tab_and_split_indices_are_zero_based = false,
    enable_scroll_bar = true,
    window_frame = {
        inactive_titlebar_bg = '#2B2042',
        active_titlebar_bg = '#2B2042',
    },
    inactive_pane_hsb = {
        saturation = 0.8,
        brightness = 0.2,
    },
}
