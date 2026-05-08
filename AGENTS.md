# AGENTS.md

## Repo type
WezTerm terminal emulator configuration for a local iMac. No build, test, or lint commands.

## Active config
`wezterm.lua` is the sole entrypoint. It uses a custom `Config` builder class (`config/init.lua`) — **not** `config_builder()`.

## Config module loading
Config modules are chained in `wezterm.lua:18-24`:
`appearance` → `bindings` → `domains` → `fonts` → `general` → `launch`

Each module returns a plain table. `Config:append()` **warns and skips duplicate keys** — later modules cannot override earlier ones.

## Event modules
Modules in `events/` follow a `setup(opts?)` pattern, registering `wezterm.on(...)` handlers via side effects. They load in `wezterm.lua:8-16`, **before** config modules.

## Backdrops singleton
`utils/backdrops.lua` is a singleton. It eagerly scans `backdrops/` for images and picks a random backdrop on config load. Methods like `:cycle_forward()`, `:toggle_focus()` mutate the singleton internally.

## Platform detection
`utils/platform.lua` exposes `is_mac`, `is_win`, `is_linux` derived from `wezterm.target_triple`. Used by bindings, domains, fonts, and launch config.

## Shell
Default shell on macOS is `/usr/local/bin/fish -l` (`config/launch.lua:10`). Launch menu includes Fish, Zsh, and Bash.

## Bindings convention
- On **macOS**: `mod.SUPER = CMD`, `mod.SUPER_REV = CMD|CTRL`
- On **Win/Linux**: `mod.SUPER = ALT`, `mod.SUPER_REV = ALT|CTRL`
- Leader key: `F12`
- Default keybindings are **disabled** (`disable_default_key_bindings = true`)

## Tab/status bar rendering
`utils/cells.lua` is a FormatItem builder for `wezterm.format()`. Used by all four tab/status-bar event modules.

## Progress indicators
`events/tab-title.lua` progress icons require WezTerm nightly ≥ version `20250209`. Older versions get `show_progress` hard-set to `false`.

## Color scheme
`colors/custom.lua` is a catppuccin mocha variant. Used by both `config/appearance.lua` and `utils/backdrops.lua`.

## Domains
`config/domains.lua` defines `ssh_domains`, `unix_domains`, `wsl_domains`. Only populated on **Windows** — empty on macOS.

## Key libraries
| File | Purpose |
|---|---|
| `utils/cells.lua` | FormatItem builder for `wezterm.format()` |
| `utils/opts-validator.lua` | Schema-based option validation |
| `utils/gpu-adapter.lua` | GPU enumeration + scoring for `webgpu_preferred_adapter` |
| `utils/platform.lua` | Platform detection singleton |
| `utils/math.lua` | `clamp`, `round` |
| `utils/str.lua` | `starts_with`, `ends_with` |
