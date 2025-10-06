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

	let line1 = [$arrowColor " ┌ "]
	let line1 = $line1 ++ [$duration]
	let line1 = $line1 ++ [$time]
	let line1 = $line1 ++ [(ansi blue) $path " "]
	let line1 = $line1 ++ [(git_prompt)]

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

def git_prompt [] {
	let in_git = match (try { $env.OS }) {
		"Windows_NT" => (git rev-parse --git-dir err> NUL | complete | get exit_code)
		_ => (git rev-parse --git-dir err> /dev/null | complete | get exit_code)
	}
	if $in_git != 0 { return "" }

	# Grab .git directory
	let git_dir = (git rev-parse --git-dir | str trim)

	# branch or detached HEAD
	let branch = match (try { $env.OS }) {
		"Windows_NT" => (
			try { git symbolic-ref --short HEAD err> NUL }
			catch { git rev-parse --short HEAD }
		)
		_ => (
			try { git symbolic-ref --short HEAD err> /dev/null }
			catch { git rev-parse --short HEAD }
		)
	}

	# Detect states
	if ($git_dir | path join "MERGE_HEAD" | path exists) {
		return $"(ansi magenta) ($branch) (ansi red)[MERGING]"
	} else if ($git_dir | path join "CHERRY_PICK_HEAD" | path exists) {
		return $"(ansi magenta) ($branch) [CHERRY-PICKING]"
	} else if ($git_dir | path join "REVERT_HEAD" | path exists) {
		return $"(ansi magenta) ($branch) (ansi red)[REVERTING]"
	} else if ($git_dir | path join "BISECT_LOG" | path exists) {
		return $"(ansi magenta) ($branch) (ansi green)[BISECTING]"
	} else if ($git_dir | path join "rebase-merge" | path exists) {
		let step  = open ($git_dir | path join "rebase-merge/msgnum") | str trim
		let total = open ($git_dir | path join "rebase-merge/end") | str trim
		let branch = open ($git_dir | path join "rebase-merge/head-name")
			| split row "/" | get 2
		return $"(ansi magenta) ($branch) (ansi yellow)[REBASE ($step)/($total)]"
	} else if ($git_dir | path join "rebase-apply" | path exists) {
		let branch = open ($git_dir | path join "rebase-merge/head-name")
			| split row "/" | get 2
		return $"(ansi magenta) ($branch) (ansi yellow)[AM/REBASE-APPLY]"
	} else {
		return $"(ansi magenta) ($branch)"
	}
}
