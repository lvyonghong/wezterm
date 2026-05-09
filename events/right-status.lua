local wezterm = require('wezterm')
local umath = require('utils.math')
local Cells = require('utils.cells')
local OptsValidator = require('utils.opts-validator')

local nf = wezterm.nerdfonts
local attr = Cells.attr

---@alias Event.RightStatusOptionsInput { date_format?: string }

---@alias Event.RightStatusOptions { date_format: string }

---Setup options for the right status bar
---@type OptsValidator
local EVENT_OPTS = OptsValidator:new({
    {
        name = 'date_format',
        type = 'string',
        default = '%a %H:%M:%S',
    },
})

local M = {}

local ICON_SEPARATOR = nf.oct_dash
local ICON_CPU = nf.md_chip
local ICON_DATE = nf.fa_calendar

---@type string[]
local discharging_icons = {
    nf.md_battery_10,
    nf.md_battery_20,
    nf.md_battery_30,
    nf.md_battery_40,
    nf.md_battery_50,
    nf.md_battery_60,
    nf.md_battery_70,
    nf.md_battery_80,
    nf.md_battery_90,
    nf.md_battery,
}
---@type string[]
local charging_icons = {
    nf.md_battery_charging_10,
    nf.md_battery_charging_20,
    nf.md_battery_charging_30,
    nf.md_battery_charging_40,
    nf.md_battery_charging_50,
    nf.md_battery_charging_60,
    nf.md_battery_charging_70,
    nf.md_battery_charging_80,
    nf.md_battery_charging_90,
    nf.md_battery_charging,
}

---@type table<string, Cells.SegmentColors>
-- stylua: ignore
local colors = {
    cpu       = { fg = '#94e2d5' },
    date      = { fg = '#fab387' },
    battery   = { fg = '#f9e2af' },
    separator = { fg = '#74c7ec' },
}

local cells = Cells:new()

cells
    :add_segment('cpu_icon', ICON_CPU .. '  ', colors.cpu, attr(attr.intensity('Bold')))
    :add_segment('cpu_text', '', colors.cpu, attr(attr.intensity('Bold')))
    :add_segment('sep_cpu', ' ' .. ICON_SEPARATOR .. '  ', colors.separator)
    :add_segment('date_icon', ICON_DATE .. '  ', colors.date, attr(attr.intensity('Bold')))
    :add_segment('date_text', '', colors.date, attr(attr.intensity('Bold')))
    :add_segment('separator', ' ' .. ICON_SEPARATOR .. '  ', colors.separator)
    :add_segment('battery_icon', '', colors.battery)
    :add_segment('battery_text', '', colors.battery, attr(attr.intensity('Bold')))

local battery_cache = { t = 0, charge = '', icon = '' }
local CPU_TTL = 1
local BATTERY_TTL = 5

---@return string, string
local function battery_info()
    -- ref: https://wezfurlong.org/wezterm/config/lua/wezterm/battery_info.html

    local now = os.time()
    if now - battery_cache.t < BATTERY_TTL then
        return battery_cache.charge, battery_cache.icon
    end

    local charge = ''
    local icon = ''

    for _, b in ipairs(wezterm.battery_info()) do
        local idx = umath.clamp(umath.round(b.state_of_charge * 10), 1, 10)
        charge = string.format('%.0f%%', b.state_of_charge * 100)

        if b.state == 'Charging' then
            icon = charging_icons[idx]
        else
            icon = discharging_icons[idx]
        end
    end

    battery_cache.t = now
    battery_cache.charge = charge
    battery_cache.icon = icon .. ' '
    return battery_cache.charge, battery_cache.icon
end

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

---@param opts? Event.RightStatusOptionsInput Default: {date_format = '%a %H:%M:%S'}
M.setup = function(opts)
    local valid_opts, err = EVENT_OPTS:validate(opts or {})

    if err then
        wezterm.log_error(err)
    end

    ---@cast valid_opts Event.RightStatusOptions

    wezterm.on('update-status', function(window, _pane)
        local cpu = cpu_load()
        local battery_text, battery_icon = battery_info()

        cells
            :update_segment_text('cpu_text', cpu)
            :update_segment_text('date_text', wezterm.strftime(valid_opts.date_format))
            :update_segment_text('battery_icon', battery_icon)
            :update_segment_text('battery_text', battery_text)

        window:set_right_status(
            wezterm.format(
                cells:render({
                    'cpu_icon', 'cpu_text', 'sep_cpu',
                    'date_icon', 'date_text',
                    'separator', 'battery_icon', 'battery_text',
                })
            )
        )
    end)
end

return M
