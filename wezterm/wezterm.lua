-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()
local scheme = wezterm.get_builtin_color_schemes()["Tokyo Night"]
local modal = require("plugin.init")
modal.apply_to_config(config)
modal.set_default_keys(config)

wezterm.on("update-right-status", function(window, _)
	modal.set_right_status(window)
end)

-- For example, changing the initial geometry for new windows:
config.initial_cols = 120
config.window_background_opacity = 0.85
config.initial_rows = 28
config.enable_wayland = true

-- or, changing the font size and color scheme.
config.font = wezterm.font("JetBrainsMonoNerdFont")
config.font_size = 13
config.color_scheme = "Tokyo Night"

config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.show_new_tab_button_in_tab_bar = false
config.tab_and_split_indices_are_zero_based = false
config.colors = {
	tab_bar = {
		background = scheme.background,
		active_tab = {
			bg_color = scheme.ansi[4], -- azul
			fg_color = scheme.background,
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = scheme.background,
			fg_color = scheme.foreground,
		},
		inactive_tab_hover = {
			bg_color = scheme.background,
			fg_color = scheme.ansi[6],
			italic = true,
		},
		new_tab = {
			bg_color = scheme.background,
			fg_color = scheme.ansi[8],
		},
		new_tab_hover = {
			bg_color = scheme.background,
			fg_color = scheme.ansi[5],
			italic = true,
		},
	},
}

local act = wezterm.action

for i = 1, 9 do
	table.insert(config.keys, {
		key = tostring(i),
		mods = "ALT",
		action = act.ActivateTab(i - 1),
	})
end
return config
