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

-- For example, changing the color scheme:
-- config.color_scheme = 'Gruvbox dark, hard (base16)'
-- config.color_scheme = 'Nature Suede (terminal.sexy)'
config.color_scheme = 'Monokai Vivid'

-- Default key bindings are listed here
-- Disable this temporarily as sending Ctrl-W tries to close the wezterm
-- This creates issue when using vim
-- TODO: Change the leader key and learn the key bindings
config.disable_default_key_bindings = true

config.keys = {
  {
    key = 'n',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ToggleFullScreen,
  },
}

-- and finally, return the configuration to wezterm
return config

