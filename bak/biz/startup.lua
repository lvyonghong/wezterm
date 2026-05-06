local wezterm = require 'wezterm'
local act = wezterm.action
local mux = wezterm.mux

wezterm.on('gui-startup', function(cmd)
    local home = wezterm.home_dir

    local m_tab, m_pane, m_window = mux.spawn_window {
        workspace = 'default',
        cwd = home
    }

    m_window:gui_window():set_position(0,0)
    m_window:gui_window():set_inner_size(3000,2000)
    m_window:gui_window():perform_action(act.ActivateTab(0), m_pane)
end)

return {}
