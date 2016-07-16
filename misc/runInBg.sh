# source this file

runInBg() {
	local SETSID=()
	if command -v perl >/dev/null 2>&1; then
		SETSID=('perl' '-e' 'use POSIX;POSIX::setsid();exec @ARGV' '--')
	elif command -v python >/dev/null 2>&1; then
		SETSID=('python' '-c'
		'import os,sys;os.setsid();os.execvp(sys.argv[1],sys.argv[1:])')
	elif command -v setsid >/dev/null 2>&1; then
		SETSID=('setsid')
	fi
	echo $(
		(
			[[ -t 0 ]] && exec </dev/null
			[[ -t 1 ]] && exec >/dev/null
			[[ -t 2 ]] && exec 2>/dev/null
			trap '' 1 2 
			eval exec {3..255}\>\&-
			umask 0022
			exec "${SETSID[@]}" "$@"
		) >/dev/null 2>&1 &
		echo $!
	)
}
