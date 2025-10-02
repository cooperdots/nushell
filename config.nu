$env.EDITOR = "nvim"
$env.config.buffer_editor = "nvim"
$env.config.show_banner = false
$env.config.table.mode = "single"

plugin add nu_plugin_gstat
plugin add ~/.cargo/bin/nu_plugin_skim

source prompt.nu
source aliases.nu
source keybinds.nu
source completion.nu
source colortheme.nu
source functions/f.nu

$env.config.history.file_format = "sqlite"
$env.config.completions.algorithm = "fuzzy"
$env.config.table.missing_value_symbol = "∅"
$env.config.cursor_shape = {
	vi_insert: "blink_line"
	vi_normal: "block"
	emacs: "blink_underscore"
}
