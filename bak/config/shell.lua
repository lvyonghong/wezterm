local utils = require("config.utils")

local M = {}

function M.apply(config)
    -- 优先使用 fish（macOS GUI 应用 PATH 受限，需检测可执行文件路径）
    local fish_paths = { "/usr/local/bin/fish", "/opt/homebrew/bin/fish" }
    for _, p in ipairs(fish_paths) do
        if utils.file_executable(p) then
            config.default_prog = { p, "-l" }
            return
        end
    end
    if utils.unix_command_exists("fish") then
        config.default_prog = { "fish", "-l" }
    elseif utils.unix_command_exists("zsh") then
        config.default_prog = { "zsh", "-l" }
    else
        config.default_prog = { "bash", "-l" }
    end
end

return M
