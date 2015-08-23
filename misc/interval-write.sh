#!/bin/bash
SCRIPT_ROOT=$(cd "${0%/*}" && echo "$PWD")
cd "$SCRIPT_ROOT" || exit

trap "kill 0" SIGKILL

#variables
interval="10"
stop=false
background=false

opts=$(getopt -o i:sb -l interval:,stop,background -- "$@")
eval set -- "${opts}"
for i; do
	case "$i" in
		-i) interval="$2"; shift; shift;;
		--interval) interval="$2"; shift; shift;;
		-s) stop=true; shift; shift;;
		--stop) stop=true; shift; shift;;
		-b) background=true; shift; shift;;
		--background) background=true; shift; shift;;
		--) shift; break;
	esac
done

interval_write() {
	while true; do
		RANDOM_ID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
		touch "./${RANDOM_ID}"
		rm -f "./${RANDOM_ID}"
		sleep "${interval}"
	done
}

if $stop; then
	kill -s SIGKILL -- -"$(<./PID)" >/dev/null 2>&1
	rm -r ./PID >/dev/null 2>&1
elif $background; then
	echo "$$" >./PID
	interval_write >/dev/null 2>&1 &
else
	interval_write
fi

exit 0
