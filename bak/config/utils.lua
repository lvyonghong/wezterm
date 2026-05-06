local wezterm = require("wezterm")

local M = {}

--- 检查命令是否存在
---@param cmd string 命令名称
---@return boolean
function M.unix_command_exists(cmd)
    local success, stdout = wezterm.run_child_process({ "sh", "-c", "command -v " .. cmd })
    return success and stdout and stdout ~= ""
end

--- 检查可执行文件是否存在（不依赖 PATH）
---@param path string 完整路径
---@return boolean
function M.file_executable(path)
    local success = wezterm.run_child_process({ "test", "-x", path })
    return success
end

return M
