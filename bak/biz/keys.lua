local wezterm = require 'wezterm'
local act = wezterm.action

-- 定义pane切换的快捷键
local function activate_pane(window, pane, pane_direction)
    window:perform_action(act.ActivatePaneDirection(pane_direction), pane)
end
wezterm.on('activate_pane_r', function(window, pane)
    activate_pane(window, pane, 'Right') 
end)
wezterm.on('activate_pane_l', function(window, pane)
    activate_pane(window, pane, 'Left')
end)
wezterm.on('activate_pane_u', function(window, pane)
    activate_pane(window, pane, 'Up')
end)
wezterm.on('activate_pane_d', function(window, pane)
    activate_pane(window, pane, 'Down')
end)

-- 构建新TAB
wezterm.on('create_new_tab', function(window, pane)
    local home = wezterm.home_dir
    local new_tab, new_pane = window:mux_window():spawn_tab({
        cwd = home .. '/.config/wezterm/cwds'
    })
   -- new_tab:set_title('temp')
   -- new_pane:send_text('wezterm_title ')
end)

return {
    -- 禁用默认key bindings,手动配置希望保留的默认绑定键
    disable_default_key_bindings = true,

    -- LEADER KEY
    leader = { key = 'F12', mods = '', timeout_milliseconds = 2000 },

    keys = {
        -- 沿用的默认快捷键
        { key = 'q', mods = 'CMD',  action = act.QuitApplication },
        { key = 'c', mods = 'CMD',  action = act.CopyTo 'Clipboard' },
        { key = 'v', mods = 'CMD',  action = act.PasteFrom 'Clipboard' },

        { key = '1', mods = 'CMD', action = act.ActivateTab(0) },
        { key = '2', mods = 'CMD', action = act.ActivateTab(1) },
        { key = '3', mods = 'CMD', action = act.ActivateTab(2) },
        { key = '4', mods = 'CMD', action = act.ActivateTab(3) },
        { key = '5', mods = 'CMD', action = act.ActivateTab(4) },
        { key = '6', mods = 'CMD', action = act.ActivateTab(5) },
        { key = '7', mods = 'CMD', action = act.ActivateTab(6) },
        { key = '8', mods = 'CMD', action = act.ActivateTab(7) },
        { key = '9', mods = 'CMD', action = act.ActivateTab(-1) },

        -- LEADER模式快捷键
        { key = 'r', mods = 'LEADER', action = act.ReloadConfiguration },
        { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
        { key = 'c', mods = 'LEADER', action = act.EmitEvent('create_new_tab') },
        { key = 'x', mods = 'LEADER', 
            action = act.CloseCurrentPane({ 
                confirm = true 
            })
        },
        { key = '|', mods = 'LEADER|SHIFT',
            action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' })
        },
        { key = '-', mods = 'LEADER',
            action = act.SplitVertical({ domain = 'CurrentPaneDomain' })
        },

        -- CMD快捷键：
        -- 切换pane
        { key = 'h', mods = 'CMD', action = act.EmitEvent('activate_pane_l') },
        { key = 'j', mods = 'CMD', action = act.EmitEvent('activate_pane_d') },
        { key = 'k', mods = 'CMD', action = act.EmitEvent('activate_pane_u') },
        { key = 'l', mods = 'CMD', action = act.EmitEvent('activate_pane_r') },

        -- 清屏
        { key = 'r', mods = 'CMD',
            action = act.Multiple {
                act.ClearScrollback 'ScrollbackAndViewport',
                act.SendKey {
                    key = 'L',
                    mods = 'CTRL'
                },
            },
        },
        -- 搜索
        { key = 'f', mods = 'CMD',
            action = act.Search {
                -- 大小写不敏感
                CaseInSensitiveString = ''
            },
        },
        -- 关闭当前窗口
        { key = 'w', mods = 'CMD',
            action = act.CloseCurrentTab {
                confirm = true
            },
        },
        -- 新建窗口
        { key = 't', mods = 'CMD',
            action = act.SpawnCommandInNewTab {
                cwd = '~',
                args = {},
            },
        },
        -- 快速移动到行首行尾
        { key = 'LeftArrow', mods = 'CMD',
            action = act.SendKey {
                key = 'Home',
                mods = 'NONE'
            },
        },
        { key = 'RightArrow', mods = 'CMD',
            action = act.SendKey {
                key = 'End',
                mods = 'NONE'
            },
        },
        -- 切换窗口大小
        { key = 'Enter', mods = 'CMD', action = act.ToggleFullScreen },
    }
}
