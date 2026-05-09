---@type Config
return {
    default_prog = { '/usr/local/bin/fish', '-l' },
    launch_menu = {
        { label = 'Fish', args = { '/usr/local/bin/fish', '-l' } },
        { label = 'Zsh',  args = { 'zsh', '-l' } },
        { label = 'Bash', args = { 'bash', '-l' } },
    },
}
