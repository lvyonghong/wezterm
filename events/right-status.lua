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
local ICON_HOSTNAME = nf.md_monitor
local ICON_DOMAIN = nf.md_earth
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
    hostname  = { fg = '#a6e3a1' },
    domain    = { fg = '#cba6f7' },
    date      = { fg = '#fab387' },
    battery   = { fg = '#f9e2af' },
    separator = { fg = '#74c7ec' },
}

local cells = Cells:new()

cells
    :add_segment('cpu_icon', ICON_CPU .. '  ', colors.cpu, attr(attr.intensity('Bold')))
    :add_segment('cpu_text', '', colors.cpu, attr(attr.intensity('Bold')))
    :add_segment('sep_cpu', ' ' .. ICON_SEPARATOR .. '  ', colors.separator)
    :add_segment('hostname_icon', ICON_HOSTNAME .. '  ', colors.hostname, attr(attr.intensity('Bold')))
    :add_segment('hostname_text', '', colors.hostname, attr(attr.intensity('Bold')))
    :add_segment('sep_host', ' ' .. ICON_SEPARATOR .. '  ', colors.separator)
    :add_segment('domain_icon', ICON_DOMAIN .. '  ', colors.domain, attr(attr.intensity('Bold')))
    :add_segment('domain_text', '', colors.domain, attr(attr.intensity('Bold')))
    :add_segment('sep_domain', ' ' .. ICON_SEPARATOR .. '  ', colors.separator)
    :add_segment('date_icon', ICON_DATE .. '  ', colors.date, attr(attr.intensity('Bold')))
    :add_segment('date_text', '', colors.date, attr(attr.intensity('Bold')))
    :add_segment('separator', ' ' .. ICON_SEPARATOR .. '  ', colors.separator)
    :add_segment('battery_icon', '', colors.battery)
    :add_segment('battery_text', '', colors.battery, attr(attr.intensity('Bold')))

---@return string, string
local function battery_info()
    -- ref: https://wezfurlong.org/wezterm/config/lua/wezterm/battery_info.html

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

    return charge, icon .. ' '
end

-- 1-minute load average via sysctl (macOS)
---@return string
local function cpu_load()
    local success, stdout, _ = wezterm.run_child_process({ 'sysctl', '-n', 'vm.loadavg' })
    if not success then
        return 'N/A'
    end
    local load = stdout:match('{ ([%d.]+) ')
    return (load or 'N/A') .. ' '
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
        local hostname = wezterm.hostname()
        local domain = window:active_pane():get_domain_name()
        local battery_text, battery_icon = battery_info()

        cells
            :update_segment_text('cpu_text', cpu)
            :update_segment_text('hostname_text', hostname)
            :update_segment_text('domain_text', domain)
            :update_segment_text('date_text', wezterm.strftime(valid_opts.date_format))
            :update_segment_text('battery_icon', battery_icon)
            :update_segment_text('battery_text', battery_text)

        window:set_right_status(
            wezterm.format(
                cells:render({
                    'cpu_icon', 'cpu_text', 'sep_cpu',
                    'hostname_icon', 'hostname_text', 'sep_host',
                    'domain_icon', 'domain_text', 'sep_domain',
                    'date_icon', 'date_text',
                    'separator', 'battery_icon', 'battery_text',
                })
            )
        )
    end)
end

return M
