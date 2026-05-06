local wezterm = require 'wezterm'

local format_title = function(title, is_active, max_width)
    local background = { Background = { Color = '#1F1F28' } }
    local title_len = #title
    local pad_len = math.floor((max_width - title_len) / 2)

    local formatted_title = {
        Text = string.rep(' ', pad_len) .. title .. string.rep(' ', pad_len)
    }
    if is_active then
        return { background = { Color = '#666666'}, { Foreground = { Color = '#BA55D3' } }, formatted_title }
    else
        return { background, { Foreground = { Color = '#957FB8' } }, formatted_title }
    end
end

local basename = function(s)
    return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
    -- host+pwd
    local title = tab.active_pane.title
    local processName = tab.active_pane.foreground_process_name
    local hostname = ''
    local isLocal = string.sub(title, 1, 1)
    if isLocal == '~' then
        hostname = 'local'
    else
        local remoteSplit = string.find(title, ':')
        if remoteSplit then
            hostname = string.sub(title, 1, remoteSplit - 1)
        end
    end

    local vTitle = tab.tab_index + 1 .. ":" .. basename(hostname)
    return format_title(vTitle, tab.is_active, max_width)
end)

local user_var_tab_title_key = 'tab_title'

wezterm.on('user-var-changed', function(window, pane, name, value)
    wezterm.log_info('var', name, value)
    if name == user_var_tab_title_key then pane:tab():set_title(value) end
end)

return {}