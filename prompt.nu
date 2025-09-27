$env.config.edit_mode = "vi"
$env.PROMPT_INDICATOR_VI_NORMAL = $"(ansi magenta)$ "
$env.PROMPT_INDICATOR_VI_INSERT = { ||
	if (is-admin) {
		return $"(ansi red)# "
	}
	$"(ansi xterm_darkorange)& "
}

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
			$arrowColor = (ansi green)
		}
		-2 => {
			$arrowChar = $arrowChars.term
			$arrowColor = (ansi red)
			$errorCode = $"($env.LAST_EXIT_CODE) "
		}
		_ => {
			$arrowChar = $arrowChars.fail
			$arrowColor = (ansi red)
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

	mut branch = gstat | get branch
	$branch = if ($branch != "no_branch") {
		$"(ansi magenta) ($branch)"
	} else {
		""
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
