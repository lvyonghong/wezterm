local wezterm = require('wezterm')
local platform = require('utils.platform')
local backdrops = require('utils.backdrops')
local act = wezterm.action

local mod = {}

if platform.is_mac then
    mod.SUPER = 'SUPER'
    mod.SUPER_REV = 'SUPER|CTRL'
elseif platform.is_win or platform.is_linux then
    mod.SUPER = 'ALT' -- to not conflict with Windows key shortcuts
    mod.SUPER_REV = 'ALT|CTRL'
end

-- stylua: ignore
---@type Key[]
local keys = {
    -- misc/useful --
    -- 进入复制模式 (Copy Mode)
    { key = 'F1',  mods = 'NONE',    action = act.ActivateCopyMode },
    -- 打开命令面板
    { key = 'F2',  mods = 'NONE',    action = act.ActivateCommandPalette },
    -- 显示启动器 (切换标签/工作区)
    { key = 'F3',  mods = 'NONE',    action = act.ShowLauncher },
    -- 模糊搜索并切换标签页
    { key = 'F4',  mods = 'NONE',    action = act.ShowLauncherArgs({ flags = 'FUZZY|TABS' }) },
    -- 模糊搜索并切换工作区
    { key = 'F5',  mods = 'NONE',    action = act.ShowLauncherArgs({ flags = 'FUZZY|WORKSPACES' }) },
    -- 切换全屏
    { key = 'F11', mods = 'NONE',    action = act.ToggleFullScreen },
    -- 显示调试叠加层 | 同时作为 Leader 键
    { key = 'F12', mods = 'NONE',    action = act.ShowDebugOverlay },
    -- CMD+f: 搜索文本 (大小写不敏感)
    { key = 'f',   mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = '' }) },
    {
        key = 'u',
        mods = mod.SUPER_REV,
        -- CMD+CTRL+u: 快速选择并打开屏幕上匹配的 URL
        action = wezterm.action.QuickSelectArgs({
            label = 'open url',
            patterns = {
                '\\((https?://\\S+)\\)',
                '\\[(https?://\\S+)\\]',
                '\\{(https?://\\S+)\\}',
                '<(https?://\\S+)>',
                '\\bhttps?://\\S+[)/a-zA-Z0-9-]+'
            },
            action = wezterm.action_callback(function(window, pane)
                local url = window:get_selection_text_for_pane(pane)
                wezterm.log_info('opening: ' .. url)
                wezterm.open_with(url)
            end),
        }),
    },

    -- cursor movement --
    -- CMD+↑: 模拟 Home 键，光标跳到行首
    { key = 'UpArrow',   mods = mod.SUPER,     action = act.SendString('\u{1b}OH') },
    -- CMD+↓: 模拟 End 键，光标跳到行尾
    { key = 'DownArrow', mods = mod.SUPER,     action = act.SendString('\u{1b}OF') },
    -- CMD+Backspace: 删除光标前整行内容 (Ctrl+U)
    { key = 'Backspace', mods = mod.SUPER,     action = act.SendString('\u{15}') },
    -- CMD+Delete: 删除光标前整行内容 (Ctrl+U)
    { key = 'Delete',    mods = mod.SUPER,     action = act.SendString('\u{15}') },

    -- copy/paste --
    -- Ctrl+Shift+c: 复制到剪贴板
    { key = 'c',         mods = 'CTRL|SHIFT',  action = act.CopyTo('Clipboard') },
    -- Ctrl+Shift+v: 从剪贴板粘贴
    { key = 'v',         mods = 'CTRL|SHIFT',  action = act.PasteFrom('Clipboard') },
    -- Ctrl+Shift+n: 输入 ♠ (黑桃花色)
    { key = 'n',         mods = 'CTRL|SHIFT',  action = act.SendString('\u{2660}') },
    -- Ctrl+Shift+s: 输入 ‽ (Interrobang 问叹号)
    { key = 's',         mods = 'CTRL|SHIFT',  action = act.SendString('\u{203D}') },
    -- tabs --
    -- tabs: spawn+close
    -- CMD+t: 新建标签页 (默认 Shell)
    { key = 't',         mods = mod.SUPER,     action = act.SpawnTab('DefaultDomain') },
    -- CMD+CTRL+t: 新建 WSL Ubuntu Fish 标签页
    { key = 't',         mods = mod.SUPER_REV, action = act.SpawnTab({ DomainName = 'wsl:ubuntu-fish' }) },
    -- CMD+CTRL+w: 关闭当前标签页 (不确认)
    { key = 'w',         mods = mod.SUPER_REV, action = act.CloseCurrentTab({ confirm = false }) },

    -- tabs: navigation
    -- CMD+[: 切换到上一个标签页
    { key = '[',         mods = mod.SUPER,     action = act.ActivateTabRelative(-1) },
    -- CMD+]: 切换到下一个标签页
    { key = ']',         mods = mod.SUPER,     action = act.ActivateTabRelative(1) },
    -- CMD+CTRL+[: 将当前标签页向左移动
    { key = '[',         mods = mod.SUPER_REV, action = act.MoveTabRelative(-1) },
    -- CMD+CTRL+]: 将当前标签页向右移动
    { key = ']',         mods = mod.SUPER_REV, action = act.MoveTabRelative(1) },

    -- tab: title
    -- CMD+0: 手动重命名当前标签页
    { key = '0',         mods = mod.SUPER,     action = act.EmitEvent('tabs.manual-update-tab-title') },
    -- CMD+CTRL+0: 重置标签页标题为自动
    { key = '0',         mods = mod.SUPER_REV, action = act.EmitEvent('tabs.reset-tab-title') },

    -- tab: hide tab-bar
    -- CMD+9: 切换标签栏显隐
    { key = '9',         mods = mod.SUPER,     action = act.EmitEvent('tabs.toggle-tab-bar') },

    -- window --
    -- window: spawn windows
    -- CMD+n: 新建 WezTerm 窗口
    { key = 'n',         mods = mod.SUPER,     action = act.SpawnWindow },

    -- window: zoom window (incrementally shrink/grow)
    -- CMD+-: 窗口缩小 50px
    {
        key = '-',
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, _pane)
            local dimensions = window:get_dimensions()
            -- on Windows 11 (the only OS I'm able to test this on), `is_full_screen` is always false (it's a bug).
            -- Calling `set_inner_size` when the window is actually in fullscreen will cause the
            -- program UI to completely freeze.
            if platform.is_win or dimensions.is_full_screen then
                return
            end
            local new_width = dimensions.pixel_width - 50
            local new_height = dimensions.pixel_height - 50
            window:set_inner_size(new_width, new_height)
        end)
    },
    -- CMD+=: 窗口放大 50px
    {
        key = '=',
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, _pane)
            local dimensions = window:get_dimensions()
            -- on Windows 11 (the only OS I'm able to test this on), `is_full_screen` is always false (it's a bug).
            -- Calling `set_inner_size` when the window is actually in fullscreen will cause the
            -- program UI to completely freeze.
            if platform.is_win or dimensions.is_full_screen then
                return
            end
            local new_width = dimensions.pixel_width + 50
            local new_height = dimensions.pixel_height + 50
            window:set_inner_size(new_width, new_height)
        end)
    },
    -- CMD+CTRL+Enter: 最大化/还原窗口
    {
        key = 'Enter',
        mods = mod.SUPER_REV,
        action = wezterm.action_callback(function(window, _pane)
            window:maximize()
        end)
    },

    -- background controls --
    -- CMD+/: 随机切换背景图片
    {
        key = [[/]],
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, _pane)
            backdrops:random(window)
        end),
    },
    -- CMD+,: 切换到上一个背景图片
    {
        key = [[,]],
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, _pane)
            backdrops:cycle_back(window)
        end),
    },
    -- CMD+.: 切换到下一个背景图片
    {
        key = [[.]],
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, _pane)
            backdrops:cycle_forward(window)
        end),
    },
    -- CMD+CTRL+/: 从模糊搜索列表中选择背景图片
    {
        key = [[/]],
        mods = mod.SUPER_REV,
        action = act.InputSelector({
            title = 'InputSelector: Select Background',
            choices = backdrops:choices(),
            fuzzy = true,
            fuzzy_description = 'Select Background: ',
            action = wezterm.action_callback(function(window, _pane, idx)
                if not idx then
                    return
                end
                ---@diagnostic disable-next-line: param-type-mismatch
                backdrops:set_img(window, tonumber(idx))
            end),
        }),
    },
    -- CMD+b: 切换聚焦模式 (纯色背景 / 图片背景)
    {
        key = 'b',
        mods = mod.SUPER,
        action = wezterm.action_callback(function(window, _pane)
            backdrops:toggle_focus(window)
        end)
    },

    -- panes --
    -- panes: split panes
    -- CMD+\: 垂直分割当前窗格
    {
        key = [[\]],
        mods = mod.SUPER,
        action = act.SplitVertical({ domain = 'CurrentPaneDomain' }),
    },
    -- CMD+CTRL+\: 水平分割当前窗格
    {
        key = [[\]],
        mods = mod.SUPER_REV,
        action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }),
    },

    -- panes: zoom+close pane
    -- CMD+Enter: 切换当前窗格缩放 (放大/还原)
    { key = 'Enter', mods = mod.SUPER,     action = act.TogglePaneZoomState },
    -- CMD+w: 关闭当前窗格 (不确认)
    { key = 'w',     mods = mod.SUPER,     action = act.CloseCurrentPane({ confirm = false }) },

    -- panes: navigation
    -- CMD+CTRL+k: 光标移到上方窗格
    { key = 'k',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Up') },
    -- CMD+CTRL+j: 光标移到下方窗格
    { key = 'j',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Down') },
    -- CMD+CTRL+l: 光标移到右方窗格
    { key = 'h',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Left') },
    -- CMD+CTRL+l: 光标移到右方窗格
    { key = 'l',     mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Right') },
    -- CMD+CTRL+p: 窗格选择器 (交换窗格位置)
    {
        key = 'p',
        mods = mod.SUPER_REV,
        action = act.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' }),
    },

    -- panes: scroll pane
    -- CMD+u: 向上滚动 5 行 (查看历史输出)
    { key = 'u',        mods = mod.SUPER, action = act.ScrollByLine(-5) },
    -- CMD+d: 向下滚动 5 行 (查看历史输出)
    { key = 'd',        mods = mod.SUPER, action = act.ScrollByLine(5) },
    -- PageUp: 向上翻页
    { key = 'PageUp',   mods = 'NONE',    action = act.ScrollByPage(-0.75) },
    -- PageDown: 向下翻页
    { key = 'PageDown', mods = 'NONE',    action = act.ScrollByPage(0.75) },

    -- key-tables (通过 Leader 键 F12 激活的子模式) --
    -- resizes fonts
    -- F12, f: 进入字体缩放模式
    {
        key = 'f',
        mods = 'LEADER',
        action = act.ActivateKeyTable({
            name = 'resize_font',
            one_shot = false,
            timeout_milliseconds = 2000,
        }),
    },
    -- resize panes
    -- F12, p: 进入窗格大小调整模式
    {
        key = 'p',
        mods = 'LEADER',
        action = act.ActivateKeyTable({
            name = 'resize_pane',
            one_shot = false,
            timeout_milliseconds = 2000,
        }),
    },
}

-- stylua: ignore
---@type table<string, Key[]>
local key_tables = {
    resize_font = {
        { key = 'k',      action = act.IncreaseFontSize }, -- 增大字号
        { key = 'j',      action = act.DecreaseFontSize }, -- 减小字号
        { key = 'r',      action = act.ResetFontSize },    -- 重置字号为默认
        { key = 'Escape', action = 'PopKeyTable' },        -- 手动退出 (1s 无操作也会自动退出)
        { key = 'q',      action = 'PopKeyTable' },        -- 手动退出 (1s 无操作也会自动退出)
    },
    resize_pane = {
        { key = 'k',      action = act.AdjustPaneSize({ 'Up', 1 }) },    -- 向上拖动窗格分割线
        { key = 'j',      action = act.AdjustPaneSize({ 'Down', 1 }) },  -- 向下拖动窗格分割线
        { key = 'h',      action = act.AdjustPaneSize({ 'Left', 1 }) },  -- 向左拖动窗格分割线
        { key = 'l',      action = act.AdjustPaneSize({ 'Right', 1 }) }, -- 向右拖动窗格分割线
        { key = 'Escape', action = 'PopKeyTable' },                      -- 手动退出 (1s 无操作也会自动退出)
        { key = 'q',      action = 'PopKeyTable' },                      -- 手动退出 (1s 无操作也会自动退出)
    },
}

---@type MouseBinding[]
local mouse_bindings = {
    -- Ctrl-click opens the link under the mouse cursor
    -- Ctrl+单击: 打开鼠标光标下的超链接
    {
        event = { Up = { streak = 1, button = 'Left' } },
        mods = 'CTRL',
        action = act.OpenLinkAtMouseCursor,
    },
}

---@type Config
return {
    disable_default_key_bindings = true,
    -- disable_default_mouse_bindings = true,
    -- F12 为 Leader 键，用于激活子模式 (key-tables)
    leader = { key = 'F12', mods = 'NONE', timeout_milliseconds = 1500 },
    keys = keys,
    key_tables = key_tables,
    mouse_bindings = mouse_bindings,
}
