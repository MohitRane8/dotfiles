local wezterm = require 'wezterm'
local act = wezterm.action

-- Use config_builder in newer wezterm versions for clearer error messages
local config = {}
if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.check_for_updates = false

-- ============================================================================
-- Fonts
-- ============================================================================
-- The Mononoki Nerd Font registers under different family names depending on
-- the host OS, so pick the right one based on where wezterm is running:
--   - Windows / WSL (wezterm runs on Windows): 'mononoki Bold'
--   - Native Linux (Ubuntu OS): 'mononoki'
local font_name = 'mononoki'
if wezterm.target_triple:find('windows') then
  font_name = 'mononoki Bold'
end
config.font = wezterm.font(font_name)
config.font_size = 11
config.line_height = 1.1
config.warn_about_missing_glyphs = false

-- ============================================================================
-- Colors
-- ============================================================================
-- color schemes I like: 'Chalk (dark) (terminal.sexy)', 'darkmoss (base16)',
--                       'dayfox', 'Derp (terminal.sexy)',
--                       'Digerati (terminal.sexy)', 'Dotshare (terminal.sexy)',
--                       'duckbones', 'Gooey (Gogh)',
--                       'Gruvbox dark, hard (base16)', 'Monokai Vivid',
--                       'Nature Suede (terminal.sexy)', 'Night Owl (Gogh)',
--                       'terafox', 'Ubuntu'
config.color_scheme = 'Gooey (Gogh)'

config.default_cursor_style = 'BlinkingBlock'

-- Override colorscheme to change cursor and selection colors
config.colors = {
  cursor_bg = '#52ad70',
  cursor_fg = 'black',
  cursor_border = '#52ad70',
  selection_fg = 'black',
  selection_bg = '#fffacd',
}

-- ============================================================================
-- Keys
-- ============================================================================
config.keys = {
  {
    key = 'n',
    mods = 'SHIFT|CTRL',
    action = act.ToggleFullScreen,
  },
  {
    key = 'Enter',
    mods = 'CTRL',
    action = act.SendString '\n',
  },
  -- Multi-line input for GitHub Copilot CLI (Shift+Enter for new line)
  {
    key = 'Enter',
    mods = 'SHIFT',
    action = act.SendString '\x1bOM',
  },
}

-- ============================================================================
-- Mouse
-- ============================================================================
-- Right-click copies the current selection to the clipboard, or pastes from
-- the clipboard when there is no active selection.
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = wezterm.action_callback(function(window, pane)
      local has_selection = window:get_selection_text_for_pane(pane) ~= ''
      if has_selection then
        window:perform_action(act.CopyTo 'ClipboardAndPrimarySelection', pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act { PasteFrom = 'Clipboard' }, pane)
      end
    end),
  },
}

-- ============================================================================
-- Window / Tabs
-- ============================================================================
config.window_padding = { left = 0, right = 0, top = 2, bottom = 0 }
config.hide_tab_bar_if_only_one_tab = true
config.enable_scroll_bar = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

-- ============================================================================
-- Background / Backdrop
-- ============================================================================
config.window_background_opacity = 1
config.win32_system_backdrop = 'Mica'

return config
