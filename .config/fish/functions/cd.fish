# Wrap the builtin cd command to maintain a permanent directory history.
function cd --description "Change directory"
	if test (count $argv) -gt 1
		printf "%s\n" (_ "Too many args for cd command")
		return 1
	end

	# Skip history in subshells.
	if status --is-command-substitution
		builtin cd $argv
		return $status
	end

	if test "$argv" = "-"
		set argv $dirprev[(math (count $dirprev) - 1)]
	end

	builtin cd $argv
	set -l cd_status $status

	if test $cd_status -eq 0
		if set -q dirprev
			## Remove duplicates.
			set -g dirprev (string match -v $PWD $dirprev) $PWD
			set -q dirprev[$fish_cdhist_max]; and set dirprev $dirprev[-$fish_cdhist_max..-1]
			## Save history.
			string join \n $dirprev > $fish_cdhist_path
		else
			set -g dirprev $PWD
		end
		set -e dirnext
		set -g __fish_cd_direction prev
	end

	return $cd_status
end