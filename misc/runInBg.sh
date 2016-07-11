# source this file

runInBg() {
	echo -n $(
		(
			[[ -t 0 ]] && exec </dev/null
			[[ -t 1 ]] && exec >/dev/null
			[[ -t 2 ]] && exec 2>/dev/null
			eval exec {3..255}\>\&-
			trap '' 1 2
			cd "/"
			umask 0
			exec perl -e 'use POSIX;POSIX::setsid();exec @ARGV' -- "$@"
		) >/dev/null 2>&1 &
		echo -n $!
	)
}
