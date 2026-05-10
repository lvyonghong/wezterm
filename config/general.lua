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

    scrollback_lines = 50000,

    hyperlink_rules = wezterm.default_hyperlink_rules(),

    -- 粘贴时把 \r\n / \r 统一成 \n，避免剪贴板里的 CR 被 shell 当回车直接执行
    canonicalize_pasted_newlines = 'CarriageReturn',

    -- 配套 ~/.terminfo/77/wezterm，解锁真彩色 / undercurl / OSC 8
    term = 'wezterm',

    -- macOS 中文输入法（搜狗/微信/系统拼音）需要 IME 通道
    use_ime = true,

    -- zoom 后切 pane 自动解除 zoom，避免误进入孤立大窗格
    unzoom_on_switch_pane = true,

    -- CJK 终端环境下的歧义宽度按双宽对齐（nvim/lazygit 表格不再错列）
    treat_east_asian_ambiguous_width_as_wide = true,

    -- 不向 wezterm.org 发起后台版本检查
    check_for_updates = false,
}
