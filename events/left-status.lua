local wezterm = require('wezterm')
local Cells = require('utils.cells')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local M = {}

local GLYPH_SEMI_CIRCLE_LEFT = nf.ple_left_half_circle_thick --[[ '' ]]
local GLYPH_SEMI_CIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[ '' ]]
local GLYPH_KEY_TABLE = nf.md_table_key --[[ '󱏅' ]]
local GLYPH_KEY = nf.md_key --[[ '󰌆' ]]

---@type table<string, Cells.SegmentColors>
local colors = {
    default = { bg = '#fab387', fg = '#1c1b19' },
    scircle = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#fab387' },
}

local cells = Cells:new()

cells
    :add_segment('scircle_left', GLYPH_SEMI_CIRCLE_LEFT, colors.scircle, attr(attr.intensity('Bold')))
    :add_segment('icon', ' ', colors.default, attr(attr.intensity('Bold')))
    :add_segment('text', ' ', colors.default, attr(attr.intensity('Bold')))
    :add_segment('scircle_right', GLYPH_SEMI_CIRCLE_RIGHT, colors.scircle, attr(attr.intensity('Bold')))

local SEGMENT_ORDER = { 'scircle_left', 'icon', 'text', 'scircle_right' }

M.setup = function()
    wezterm.on('update-status', function(window, _pane)
        local name = window:active_key_table()
        local res = {}

        if window:leader_is_active() then
            cells:update_segment_text('icon', GLYPH_KEY):update_segment_text('text', ' ')
            res = cells:render(SEGMENT_ORDER)
        elseif name then
            cells
                :update_segment_text('icon', GLYPH_KEY_TABLE)
                :update_segment_text('text', ' ' .. string.upper(name))
            res = cells:render(SEGMENT_ORDER)
        end
        window:set_left_status(wezterm.format(res))
    end)
end

return M
