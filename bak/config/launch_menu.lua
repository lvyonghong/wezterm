local M = {}

function M.apply(config)
    config.launch_menu = {
        -- Shell
        { label = "Bash",           args = { "bash", "-l" } },
        { label = "Zsh",            args = { "zsh", "-l" } },
        { label = "Fish",           args = { "fish", "-l" } },

        -- SSH 连接
        { label = "SSH: linuxbrew", args = { "ssh", "linuxbrew@122.207.79.209" } },
        { label = "SSH: software",  args = { "ssh", "software@122.207.79.209" } },
    }
end

return M
