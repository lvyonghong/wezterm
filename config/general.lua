---@type Config
return {
    -- behaviours
    -- 自动重载配置
    automatically_reload_config = true,
    -- 退出行为
    exit_behavior = 'CloseOnCleanExit', -- if the shell program exited with a successful status
    exit_behavior_messaging = 'Verbose',
    -- 状态更新间隔
    status_update_interval = 5000,
    audible_bell = 'Disabled',

    scrollback_lines = 100000,

    hyperlink_rules = {
        -- Matches: a URL in parens: (URL)
        {
            regex = '\\((\\w+://\\S+)\\)',
            format = '$1',
            highlight = 1,
        },
        -- Matches: a URL in brackets: [URL]
        {
            regex = '\\[(\\w+://\\S+)\\]',
            format = '$1',
            highlight = 1,
        },
        -- Matches: a URL in curly braces: {URL}
        {
            regex = '\\{(\\w+://\\S+)\\}',
            format = '$1',
            highlight = 1,
        },
        -- Matches: a URL in angle brackets: <URL>
        {
            regex = '<(\\w+://\\S+)>',
            format = '$1',
            highlight = 1,
        },
        -- Then handle URLs not wrapped in brackets
        {
            regex = '\\b\\w+://\\S+[)/a-zA-Z0-9-]+',
            format = '$0',
        },
        -- implicit mailto link
        {
            regex = '\\b\\w+@[\\w-]+(\\.[\\w-]+)+\\b',
            format = 'mailto:$0',
        },
    },
}
