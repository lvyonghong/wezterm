local wezterm = require('wezterm')

---@type Config
return {
    -- behaviours
    -- 自动重载配置
    automatically_reload_config = true,
    -- 退出行为
    exit_behavior = 'CloseOnCleanExit',
    exit_behavior_messaging = 'Brief',
    -- 状态更新间隔
    status_update_interval = 5000,
    audible_bell = 'Disabled',

    scrollback_lines = 100000,

    hyperlink_rules = wezterm.default_hyperlink_rules(),
}
