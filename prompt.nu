$env.config.edit_mode = "vi"
$env.PROMPT_INDICATOR_VI_NORMAL = $"(ansi magenta)$ "
$env.PROMPT_INDICATOR_VI_INSERT = { ||
	if (try { sudo -n true err> /dev/null; true } catch { false }) {
		return $"(ansi light_red)# "
	}
	$"(ansi xterm_darkorange)& "
}

$env.PROMPT_MULTILINE_INDICATOR = $"(ansi grey)    │ "
$env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = $"(ansi grey)    │ "
$env.PROMPT_COMMAND_RIGHT = ""

$env.PROMPT_COMMAND = { ||
	let arrowChars = {
		pass: "‣ "
		fail: "× "
		term: "■ "
	}

	mut arrowChar = ""
	mut arrowColor = ""
	mut errorCode = ""
	match $env.LAST_EXIT_CODE {
		0 => {
			$arrowChar = $arrowChars.pass
			$arrowColor = (ansi light_green)
		}
		-2 | 130 => {
			$arrowChar = $arrowChars.term
			$arrowColor = (ansi light_red)
		}
		_ => {
			$arrowChar = $arrowChars.fail
			$arrowColor = (ansi light_red)
			$errorCode = $"($env.LAST_EXIT_CODE) "
		}
	}

	let durationRaw = ($env.CMD_DURATION_MS | into duration --unit ms)
	mut duration = ""
	if $durationRaw > 9ms {
		$duration = $"(ansi grey)($durationRaw) "
	}

	let time = date now | format date "%H:%M:%S"
	let time = $"(ansi yellow)($time) "

	let path = match (pwd | path split) {
		["/", "home", "coop", "ghq", "github.com", ..$repo] => (" " + ($repo | path join))
		["/", "home", "coop", ..$rest] => (["~"] ++ (format-path $rest) | path join)
		["/", ..$rest] => ("/" + (format-path $rest | path join))
	}

	let branch = try { git branch --show-current err> /dev/null } catch { "" }
	let branch = match $branch {
		"" => ""
		$branch => $"(ansi magenta) ($branch)"
	}

	let line1 = [$arrowColor " ┌ "]
	let line1 = $line1 ++ [$duration]
	let line1 = $line1 ++ [$time]
	let line1 = $line1 ++ [(ansi blue) $path " "]
	let line1 = $line1 ++ [$branch]

	let line2 = [$arrowColor " └" $arrowChar]
	let line2 = $line2 ++ [$errorCode]

	($line1 | str join) + "\n" + ($line2 | str join)
}

def format-path [path] {
	let length = $path | length
	$path | enumerate | each { |item|
		if $item.item == "/" {
			""
		} else if $item.index == $length - 1 {
			$item.item
		} else {
			let cutoff = if ($item.item | str starts-with ".") { 1 } else { 0 }
			$item.item | str substring ..$cutoff
		}
	}
}
