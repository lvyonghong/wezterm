local wezterm = require('wezterm')
local Cells = require('utils.cells')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

local ICON_SEPARATOR = nf.oct_dash
local ICON_CPU = nf.md_chip
local ICON_MEM = nf.md_memory

---@type table<string, Cells.SegmentColors>
-- stylua: ignore
local colors = {
    cpu       = { fg = '#94e2d5' },
    memory    = { fg = '#fab387' },
    separator = { fg = '#74c7ec' },
}

local cells = Cells:new()

cells
    :add_segment('cpu_icon', ICON_CPU .. '  ', colors.cpu, attr(attr.intensity('Bold')))
    :add_segment('cpu_text', '', colors.cpu, attr(attr.intensity('Bold')))
    :add_segment('sep_cpu', ' ' .. ICON_SEPARATOR .. '  ', colors.separator)
    :add_segment('mem_icon', ICON_MEM .. '  ', colors.memory, attr(attr.intensity('Bold')))
    :add_segment('mem_text', '', colors.memory, attr(attr.intensity('Bold')))

local CPU_TTL = 1
local MEM_TTL = 2

-- 总物理内存（字节）启动时取一次，运行时不变
local TOTAL_MEM = (function()
    local ok, out = wezterm.run_child_process({ 'sysctl', '-n', 'hw.memsize' })
    return ok and tonumber((out:match('%d+'))) or 0
end)()

local cpu_cache = { t = 0, v = 'N/A ' }

-- 1-minute load average via sysctl (macOS)
---@return string
local function cpu_load()
    local now = os.time()
    if now - cpu_cache.t < CPU_TTL then
        return cpu_cache.v
    end
    local success, stdout, _ = wezterm.run_child_process({ 'sysctl', '-n', 'vm.loadavg' })
    local load = success and stdout:match('{ ([%d.]+) ') or nil
    cpu_cache.v = (load or 'N/A') .. ' '
    cpu_cache.t = now
    return cpu_cache.v
end

local mem_cache = { t = 0, v = 'N/A ' }

-- 内存使用率：(总量 - 可用) / 总量。可用 ≈ free + inactive 页（macOS 复用此口径）
---@return string
local function mem_usage()
    local now = os.time()
    if now - mem_cache.t < MEM_TTL then
        return mem_cache.v
    end
    if TOTAL_MEM == 0 then
        return 'N/A '
    end
    local ok, out = wezterm.run_child_process({ 'vm_stat' })
    if not ok then
        return 'N/A '
    end
    local page_size = tonumber(out:match('page size of (%d+)')) or 4096
    local free = tonumber(out:match('Pages free:%s+(%d+)')) or 0
    local inactive = tonumber(out:match('Pages inactive:%s+(%d+)')) or 0
    local available = (free + inactive) * page_size
    local pct = math.floor((1 - available / TOTAL_MEM) * 100 + 0.5)
    mem_cache.v = string.format('%d%% ', pct)
    mem_cache.t = now
    return mem_cache.v
end

local RENDER_ORDER = {
    'cpu_icon', 'cpu_text', 'sep_cpu',
    'mem_icon', 'mem_text',
}

M.setup = function()
    wezterm.on('update-status', function(window, _pane)
        cells
            :update_segment_text('cpu_text', cpu_load())
            :update_segment_text('mem_text', mem_usage())

        window:set_right_status(wezterm.format(cells:render(RENDER_ORDER)))
    end)
end

return M
