-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

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
config.font = wezterm.font('Consolas')
config.font_size = 12
config.line_height = 1.1

-- For example, changing the color scheme:
config.color_scheme = 'Gruvbox dark, hard (base16)'
-- config.color_scheme = 'Nature Suede (terminal.sexy)'
-- config.color_scheme = 'Monokai Vivid'
-- config.color_scheme = 'Ubuntu'
-- config.color_scheme = 'Chalk (dark) (terminal.sexy)'
-- config.color_scheme = 'dayfox'
-- config.color_scheme = 'darkmoss (base16)'
-- config.color_scheme = 'Derp (terminal.sexy)'
-- config.color_scheme = 'Digerati (terminal.sexy)'
config.color_scheme = 'Dotshare (terminal.sexy)'
-- config.color_scheme = 'terafox'
-- config.color_scheme = 'duckbones'


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

-- Select in wezterm with mouse to copy to clipboard
-- Right click in wezterm to paste the text from clipboard
config.mouse_bindings = {
	{
		event = { Down = { streak = 1, button = "Right" } },
		mods = "NONE",
		action = wezterm.action_callback(function(window, pane)
			local has_selection = window:get_selection_text_for_pane(pane) ~= ""
			if has_selection then
				window:perform_action(act.CopyTo("ClipboardAndPrimarySelection"), pane)
				window:perform_action(act.ClearSelection, pane)
			else
				window:perform_action(act({ PasteFrom = "Clipboard" }), pane)
			end
		end),
	},
}

config.window_padding = { left = '0', right = '0', top = '2', bottom = '0', }
config.hide_tab_bar_if_only_one_tab = true
config.enable_scroll_bar = false
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false

config.warn_about_missing_glyphs = false

-- background
-- config.window_background_opacity = 1
-- config.window_background_image = "c:/users/mrane/Pictures/wall_22.png"
-- config.window_background_image = "c:/users/mrane/Pictures/blur_4.jpg"
-- config.window_background_image_hsb = {
--   brightness = 0.07,
--   hue = 1.0,
--   saturation = 0.7,
-- }

-- and finally, return the configuration to wezterm
return config

