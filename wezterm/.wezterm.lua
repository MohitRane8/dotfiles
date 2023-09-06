-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- This is where you actually apply your config choices
-- disable update checks
config.check_for_updates = false

-- Font size
config.font_size = 11.0

-- For example, changing the color scheme:
-- config.color_scheme = 'Gruvbox dark, hard (base16)'
-- config.color_scheme = 'Nature Suede (terminal.sexy)'
config.color_scheme = 'Monokai Vivid'

config.default_cursor_style = 'BlinkingBlock'

-- Override colorscheme to change cursor color
config.colors = {
  -- Overrides the cell background color when the current cell is occupied by the
  -- cursor and the cursor style is set to Block
  cursor_bg = '#52ad70',
  -- Overrides the text color when the current cell is occupied by the cursor
  cursor_fg = 'black',
  -- Specifies the border color of the cursor when the cursor style is set to Block,
  -- or the color of the vertical or horizontal bar when the cursor style is set to
  -- Bar or Underline.
  cursor_border = '#52ad70',

  -- the foreground color of selected text
  selection_fg = 'black',
  -- the background color of selected text
  selection_bg = '#fffacd',
}

-- Default key bindings are listed here
-- Disable this temporarily as sending Ctrl-W tries to close the wezterm
-- This creates issue when using vim
-- TODO: Change the leader key and learn the key bindings
-- config.disable_default_key_bindings = true

config.keys = {
  {
    key = 'n',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ToggleFullScreen,
  },
}

-- and finally, return the configuration to wezterm
return config

