#!/bin/bash

#variables
rsyncURI=""
targetDirectory=""
background=false
rsyncDefaultParameters="-rtvplP"
rsyncExtraParameters=()
ARGC=$#

opts=$(getopt -o u:d:bne: -l uri:,dir:,background,no-defaults,extra-param: -- "$@")
eval set -- "${opts}"
for i; do
	case "$i" in
		-u) rsyncURI="$2"; shift; shift;;
		--uri) rsyncURI="$2"; shift; shift;;
		-d) targetDirectory="$2"; shift; shift;;
		--dir) targetDirectory="$2"; shift; shift;;
		-b) background=true; shift;;
		--background) background=true; shift;;
                -n) rsyncDefaultParameters=""; shift;;
                --no-defaults) rsyncDefaultParameters=""; shift;;
                -e) rsyncExtraParameters+=("$2"); shift; shift;;
                --extra-param) rsyncExtraParameters+=("$2"); shift; shift;;
		--) shift; break;
	esac
done

mirrorRsync() {
	rsync "${rsyncDefaultParameters}" "${rsyncExtraParameters[@]}" $1 $2
}

if [ $ARGC -eq 0 ]; then
	echo "Specify rsync uri and target directory"
	echo "Example: $0 -u rsync://server.tld/module/src -d '/my/path/dest'"
elif test -n "${rsyncURI}" && test -n "${targetDirectory}"; then
	if test "${background}" = true; then
		nohup mirrorRsync "${rsyncURI}" "${targetDirectory}" >/dev/null 2>&1 &
		disown -a >/dev/null 2>&1
		exit 0
	else
		mirrorRsync "${rsyncURI}" "${targetDirectory}"
	fi
fi
