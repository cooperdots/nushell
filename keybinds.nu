if ($env.TMUX? | is-empty) {
	$env.config.keybindings ++= [
		{
			name: start_tmux
			modifier: control
			keycode: char_a
			mode: vi_insert
			event: {
				send: executehostcommand,
				cmd: "tmux new-session -A"
			}
		}
	]
}
