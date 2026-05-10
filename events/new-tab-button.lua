local wezterm = require('wezterm')
local launch_menu = require('config.launch').launch_menu
local Cells = require('utils.cells')

local nf = wezterm.nerdfonts
local act = wezterm.action
local attr = Cells.attr

local M = {}

---@type table<string, Cells.SegmentColors>
local colors = {
    label_text   = { fg = '#CDD6F4' },
    icon_default = { fg = '#89B4FA' },
}

local cells = Cells:new()
    :add_segment('icon_default', ' ' .. nf.oct_terminal .. ' ', colors.icon_default)
    :add_segment('label_text', '', colors.label_text, attr(attr.intensity('Bold')))

local function build_choices()
    local choices = {}
    local choices_data = {}

    for idx, v in ipairs(launch_menu) do
        cells:update_segment_text('label_text', v.label)
        table.insert(choices, {
            id = tostring(idx),
            label = wezterm.format(cells:render({ 'icon_default', 'label_text' })),
        })
        table.insert(choices_data, {
            args = v.args,
            domain = 'DefaultDomain',
        })
    end

    return choices, choices_data
end

local choices, choices_data = build_choices()

M.setup = function()
    wezterm.on('new-tab-button-click', function(window, pane, button, _default_action)
        if button == 'Right' then
            window:perform_action(
                act.InputSelector({
                    title = 'InputSelector: Launch Menu',
                    choices = choices,
                    fuzzy = true,
                    fuzzy_description = nf.md_rocket .. ' Select a launch item: ',
                    action = wezterm.action_callback(function(inner_window, inner_pane, id, _label)
                        if not id then
                            return
                        end
                        inner_window:perform_action(
                            act.SpawnCommandInNewTab(choices_data[tonumber(id)]),
                            inner_pane
                        )
                    end),
                }),
                pane
            )
            return true
        end

        return false
    end)
end

return M
