local wezterm = require('wezterm')
local backdrops = require('utils.backdrops')
local act = wezterm.action

local mod = {
    SUPER = 'SUPER',
    SUPER_REV = 'SUPER|CTRL',
}

-- stylua: ignore
---@type Key[]
local keys = {
    -- misc/useful --
    -- 进入复制模式 (Copy Mode)
    { key = 'F1',    mods = 'NONE',    action = act.ActivateCopyMode },
    -- 打开命令面板
    { key = 'F2',    mods = 'NONE',    action = act.ActivateCommandPalette },
    -- 显示启动器 (切换标签/工作区)
    { key = 'F3',    mods = 'NONE',    action = act.ShowLauncher },
    -- 切换全屏
    { key = 'Enter', mods = mod.SUPER, action = act.ToggleFullScreen },
    -- CMD+F12: 显示调试叠加层（注意：不带 mods 的 F12 是 Leader 键，见底部 leader 配置）
    { key = 'F12',   mods = mod.SUPER, action = act.ShowDebugOverlay },
    -- CMD+f: 搜索文本 (大小写不敏感)
    { key = 'f',     mods = mod.SUPER, action = act.Search({ CaseInSensitiveString = '' }) },
    -- 清屏（macOS 习惯的 CMD+k）
    {
        key = 'k',
        mods = mod.SUPER,
        action = act.Multiple {
            act.ClearScrollback 'ScrollbackAndViewport',
            act.SendKey { key = 'L', mods = 'CTRL' },
        },
    },
    -- CMD + z 发送 Ctrl+_ 实现撤销
    { key = 'z',          mods = mod.SUPER,     action = act.SendKey { key = '_', mods = 'CTRL' } },

    -- CMD+CTRL+u: 快速选择并打开屏幕上匹配的 URL
    {
        key = 'u',
        mods = mod.SUPER_REV,
        action = act.QuickSelectArgs({
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
    -- CMD+←: 模拟 Home 键，光标跳到行首
    { key = 'LeftArrow',  mods = mod.SUPER,     action = act.SendString('\u{1b}OH') },
    -- CMD+→: 模拟 End 键，光标跳到行尾
    { key = 'RightArrow', mods = mod.SUPER,     action = act.SendString('\u{1b}OF') },
    -- CMD+Delete: 删除光标前整行内容 (Ctrl+U)
    { key = 'Backspace',  mods = mod.SUPER,     action = act.SendString('\u{15}') },

    -- copy/paste --
    -- CMD+c: 复制到剪贴板
    { key = 'c',          mods = mod.SUPER,     action = act.CopyTo 'Clipboard' },
    -- CMD+Shift+v: 从剪贴板粘贴
    { key = 'v',          mods = mod.SUPER,     action = act.PasteFrom 'Clipboard' },

    -- tabs --
    -- tabs: spawn+close
    -- CMD+t: 新建标签页 (默认 Shell)
    { key = 't',          mods = mod.SUPER,     action = act.SpawnTab('DefaultDomain') },
    -- CMD+CTRL+w: 关闭当前标签页 (不确认)
    { key = 'w',          mods = mod.SUPER_REV, action = act.CloseCurrentTab({ confirm = false }) },

    -- tabs: navigation
    -- CMD+Shift+[/]: Chrome/Safari 风格的 tab 切换别名
    { key = '{',          mods = 'SUPER|SHIFT', action = act.ActivateTabRelative(-1) },
    { key = '}',          mods = 'SUPER|SHIFT', action = act.ActivateTabRelative(1) },
    -- CMD+CTRL+[: 将当前标签页向左移动
    { key = '[',          mods = mod.SUPER_REV, action = act.MoveTabRelative(-1) },
    -- CMD+CTRL+]: 将当前标签页向右移动
    { key = ']',          mods = mod.SUPER_REV, action = act.MoveTabRelative(1) },
    -- CMD+数字: 切换到对应序号的标签页
    { key = '1',          mods = mod.SUPER,     action = act.ActivateTab(0) },
    { key = '2',          mods = mod.SUPER,     action = act.ActivateTab(1) },
    { key = '3',          mods = mod.SUPER,     action = act.ActivateTab(2) },
    { key = '4',          mods = mod.SUPER,     action = act.ActivateTab(3) },
    { key = '5',          mods = mod.SUPER,     action = act.ActivateTab(4) },
    { key = '6',          mods = mod.SUPER,     action = act.ActivateTab(5) },
    { key = '7',          mods = mod.SUPER,     action = act.ActivateTab(6) },
    { key = '8',          mods = mod.SUPER,     action = act.ActivateTab(7) },

    -- tab: title
    -- CMD+0: 手动重命名当前标签页
    { key = '0',          mods = mod.SUPER,     action = act.EmitEvent('tabs.manual-update-tab-title') },
    -- CMD+CTRL+0: 重置标签页标题为自动
    { key = '0',          mods = mod.SUPER_REV, action = act.EmitEvent('tabs.reset-tab-title') },

    -- tab: hide tab-bar
    -- CMD+9: 切换标签栏显隐
    { key = '9',          mods = mod.SUPER,     action = act.EmitEvent('tabs.toggle-tab-bar') },

    -- window --
    -- window: spawn windows
    -- CMD+n: 新建 WezTerm 窗口
    { key = 'n',          mods = mod.SUPER,     action = act.SpawnWindow },

    -- CMD+CTRL+Enter: 最大化/还原窗口
    {
        key = 'Enter',
        mods = mod.SUPER_REV,
        action = wezterm.action_callback(function(window, _pane)
            window:maximize()
        end)
    },

    -- background controls --
    -- CMD+,: 切换到上一个背景图片
    {
        key = [[,]],
        mods = mod.SUPER_REV,
        action = wezterm.action_callback(function(window, _pane)
            backdrops:cycle_back(window)
        end),
    },
    -- CMD+.: 切换到下一个背景图片
    {
        key = [[.]],
        mods = mod.SUPER_REV,
        action = wezterm.action_callback(function(window, _pane)
            backdrops:cycle_forward(window)
        end),
    },
    -- CMD+b: 切换聚焦模式 (纯色背景 / 图片背景)
    {
        key = 'b',
        mods = mod.SUPER_REV,
        action = wezterm.action_callback(function(window, _pane)
            backdrops:toggle_focus(window)
        end)
    },

    -- panes --
    -- panes: split panes
    -- CMD+\: 垂直分割当前窗格
    { key = [[\]],      mods = mod.SUPER,     action = act.SplitVertical({ domain = 'CurrentPaneDomain' }) },
    -- CMD+CTRL+\: 水平分割当前窗格
    { key = [[\]],      mods = mod.SUPER_REV, action = act.SplitHorizontal({ domain = 'CurrentPaneDomain' }) },

    -- panes: close pane
    -- CMD+w: 关闭当前窗格 (不确认)
    { key = 'w',        mods = mod.SUPER,     action = act.CloseCurrentPane({ confirm = false }) },

    -- panes: navigation
    -- CMD+CTRL+k: 光标移到上方窗格
    { key = 'k',        mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Up') },
    -- CMD+CTRL+j: 光标移到下方窗格
    { key = 'j',        mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Down') },
    -- CMD+CTRL+h: 光标移到左方窗格
    { key = 'h',        mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Left') },
    -- CMD+CTRL+l: 光标移到右方窗格
    { key = 'l',        mods = mod.SUPER_REV, action = act.ActivatePaneDirection('Right') },
    -- CMD+CTRL+p: 窗格选择器 (交换窗格位置)
    { key = 'p',        mods = mod.SUPER_REV, action = act.PaneSelect({ alphabet = '1234567890', mode = 'SwapWithActiveKeepFocus' }) },

    -- panes: scroll pane
    -- CMD+u: 向上滚动 5 行 (查看历史输出)
    { key = 'u',        mods = mod.SUPER,     action = act.ScrollByLine(-5) },
    -- CMD+d: 向下滚动 5 行 (查看历史输出)
    { key = 'd',        mods = mod.SUPER,     action = act.ScrollByLine(5) },
    -- PageUp: 向上翻页
    { key = 'PageUp',   mods = 'NONE',        action = act.ScrollByPage(-0.75) },
    -- PageDown: 向下翻页
    { key = 'PageDown', mods = 'NONE',        action = act.ScrollByPage(0.75) },

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
    -- F12 为 Leader 键，用于激活子模式 (key-tables)
    leader = { key = [[\]], mods = 'NONE', timeout_milliseconds = 2000 },
    keys = keys,
    key_tables = key_tables,
    mouse_bindings = mouse_bindings,
}
