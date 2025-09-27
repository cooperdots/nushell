def f-completion [] { {
	options: { completion_algorithm: fuzzy }
	completions: (
		ls ~/ghq/*/*/*
		| where type == dir
		| get name
		| path split
		| each { |repo| {
			value: ($repo | slice 5.. | path join)
			description: ($repo | get 4)
		}}
	)
}}

def --env f [repo: path@f-completion] {
	cd ~/ghq/github.com
	cd $repo
	ls
}
