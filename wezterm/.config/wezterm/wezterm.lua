local wezterm = require 'wezterm'
local mux = wezterm.mux
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
-- Unpatched mononoki for text. WezTerm's bundled Nerd Font Symbols cover icons.
-- Windows registers the face as family 'mononoki Bold'; Ubuntu uses weight.
local font = wezterm.font_with_fallback {
  { family = 'mononoki', weight = 'Bold' },
}
if wezterm.target_triple:find('windows') then
  font = wezterm.font('mononoki Bold')
end
config.font = font
config.font_size = 14
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
config.color_scheme = 'Derp (terminal.sexy)'

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
-- Wayland/GNOME applies maximize asynchronously. Fullscreen before that
-- uses the default small geometry (bottom-right). Wait until the window
-- actually grows, then fullscreen. Timer is a fallback if resize is skipped.
local startup_fullscreen = { pending = true, width = nil, height = nil }

local function apply_startup_fullscreen(window)
  if not startup_fullscreen.pending then
    return
  end
  local dims = window:get_dimensions()
  if dims.is_full_screen then
    startup_fullscreen.pending = false
    return
  end
  if not startup_fullscreen.width then
    startup_fullscreen.width = dims.pixel_width
    startup_fullscreen.height = dims.pixel_height
    return
  end
  if
    dims.pixel_width > startup_fullscreen.width + 50
    or dims.pixel_height > startup_fullscreen.height + 50
  then
    startup_fullscreen.pending = false
    window:toggle_fullscreen()
  end
end

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  local gui_window = window:gui_window()
  gui_window:maximize()
  wezterm.time.call_after(0.5, function()
    if startup_fullscreen.pending then
      startup_fullscreen.pending = false
      gui_window:maximize()
      gui_window:toggle_fullscreen()
    end
  end)
end)

wezterm.on('window-resized', function(window, pane)
  apply_startup_fullscreen(window)
end)

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
