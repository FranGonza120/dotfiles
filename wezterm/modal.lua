local wezterm = require("wezterm")

local modal = wezterm.plugin.require("https://github.com/MLFlexer/modal.wezterm")

local M = {}

function M.apply(config)
	modal.apply_to_config(config)
	modal.set_default_keys(config)
end

return M
