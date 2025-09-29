$env.config.highlight_resolved_externals = true

$env.config.color_config.filesize = { |x|
	if $x == 0b { 'dark_gray' } else if $x < 1mb { 'cyan' } else { 'blue' }
}
$env.config.color_config.bool = { |x|
	if $x { 'green' } else { 'light_red' }
}
$env.config.color_config.shape_external = "light_red"
$env.config.color_config.shape_external_resolved = "yellow"
$env.config.color_config.shape_flag = "grey"
$env.config.color_config.shape_externalarg = "green"

$env.config.color_config.separator = "grey"
$env.config.color_config.nothing = "red"
$env.config.color_config.shape_closure = "purple"
$env.config.color_config.shape_pipe = "purple"
