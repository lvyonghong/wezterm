# AGENTS.md

## Repo type
WezTerm terminal emulator configuration. No build, test, or lint commands.

## Active config
Only `wezterm.lua` (root) is loaded by WezTerm. It uses `config_builder()` and requires modules from `config/` in a defined order (see `modules` table at line 12). Each module exports an `apply(config)` function.

## Legacy/biz config
`biz/wezterm.lua` is an older alternative config (returns a plain table, not config_builder). It is **not** loaded by the root config. The `biz/` directory is only relevant if this config is used standalone on another machine.

## Module loading order
Defined in `wezterm.lua:12-27`. Order matters — later modules can override earlier ones. `config.background` is commented out by default; uncomment to enable wallpaper rotation.

## Sensitive data
`config/ssh_domains.lua` contains real IPs and usernames. Do not commit sensitive changes there.

## Fonts
`fonts/` is empty. The config uses system-installed `JetBrainsMono Nerd Font Mono`. The commented-out `font_dirs` / `font_locator` lines in `config/fonts.lua:8-9` show how to bundle fonts for portability.

## Image directory
`images/` contains wallpaper files (`.jpg`) used by `config/background.lua` for background rotation (disabled by default).

## Platform-aware behavior
`config/shell.lua` and `config/utils.lua` detect Windows vs Unix to select default shell and check for commands. The repo is used cross-platform.

## Config resolution
`config/constants.lua` exposes `CONFIG_DIR` as `wezterm.config_dir` (runtime path). Use this for referencing files relative to the config directory.

## Event handlers
Some modules register global `wezterm.on(...)` handlers (`config/events.lua`, `config/tab_bar.lua`, `biz/title.lua`, `biz/startup.lua`). These register at module load time and persist regardless of config reloads.

## Other
`biz` 目录下的配置是另外一种配置方式，在这里仅作为参考，供主配置文件参考使用。