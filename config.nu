$env.EDITOR = "nvim"
$env.config.buffer_editor = "nvim"
$env.config.show_banner = false

$env.config.color_config.filesize = { |x|
	if $x == 0b { 'dark_gray' } else if $x < 1mb { 'cyan' } else { 'blue' }
}
$env.config.color_config.bool = { |x|
	if $x { 'green' } else { 'light_red' }
}
$env.config.table.mode = "single"

plugin add nu_plugin_gstat
plugin add ~/.cargo/bin/nu_plugin_skim

source prompt.nu
source aliases.nu
source keybinds.nu
source completion.nu
source functions/f.nu

$env.config.table.missing_value_symbol = "∅"
