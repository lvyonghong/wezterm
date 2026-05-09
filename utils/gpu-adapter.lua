local wezterm = require('wezterm')

---Backend options available on macOS.
---Higher the score, the better the backend.
---See `https://github.com/gfx-rs/wgpu#supported-platforms` for more info on available backends
-- stylua: ignore
local AVAILABLE_BACKENDS = { Metal = 1 }

---Device type options available.
---Higher the score, the better the device type.
-- stylua: ignore
local AVAILABLE_DEVICE_TYPES = {
    DiscreteGpu   = 4 * 100,
    IntegratedGpu = 3 * 100,
    Other         = 2 * 100,
    Cpu           = 1 * 100,
}

---@type GpuInfo[]
local ENUMERATED_GPUS = wezterm.gui.enumerate_gpus()

---@class GpuAdapters
---@field scoreboard {[number]: GpuInfo}
---@field best number
local GpuAdapters = {}
GpuAdapters.__index = GpuAdapters
GpuAdapters.backends = AVAILABLE_BACKENDS
GpuAdapters.device_types = AVAILABLE_DEVICE_TYPES

---@return GpuAdapters
---@private
function GpuAdapters:init()
    local initial = {
        scoreboard = {},
        best = 0,
    }

    -- iterate over the enumerated GPUs and create a `scoreboard` look-up-table
    -- where higher the score, the better the adapter
    for _, adapter in ipairs(ENUMERATED_GPUS) do
        local backend_score = self.backends[adapter.backend]
        local device_score = self.device_types[adapter.device_type]
        if backend_score and device_score then
            local score = backend_score + device_score
            if score > initial.best then
                initial.best = score
            end
            initial.scoreboard[score] = adapter
        end
    end

    return setmetatable(initial, self)
end

---Will pick the best adapter based on the following criteria:
---   1. Best GPU available (Discrete > Integrated > Other > Cpu)
---   2. Best graphics API available (Mac: Metal)
---
---@see AVAILABLE_BACKENDS
---
---If the best adapter combo is not found, it will return `nil` and lets Wezterm decide the best adapter.
---
---Please note these are my own personal preferences and may not be the best for your system.
---If you want to manually choose the adapter, use `GpuAdapters:pick_manual(backend, device_type)`
---Or feel free to change the point allocated to the backends in `AVAILABLE_BACKENDS` to your liking.
---@return GpuInfo|nil
function GpuAdapters:pick_best()
    return self.best > 0 and self.scoreboard[self.best] or nil
end

---Manually pick the adapter based on the backend and device type.
---If the adapter is not found, it will return nil and lets Wezterm decide the best adapter.
---@param backend GpuInfo.Backend
---@param device_type GpuInfo.DeviceType
---@return GpuInfo|nil
function GpuAdapters:pick_manual(backend, device_type)
    local backend_score = self.backends[backend]
    local device_type_score = self.device_types[device_type]

    assert(backend_score, 'Invalid backend provided')
    assert(device_type_score, 'Invalid device type provided')

    local score = backend_score + device_type_score
    local adapter_choice = self.scoreboard[score]

    if not adapter_choice then
        wezterm.log_error('Preferred backend not available. Using Default Adapter.')
        return nil
    end

    return adapter_choice
end

return GpuAdapters:init()
