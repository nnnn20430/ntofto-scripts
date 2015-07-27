#!/bin/bash
SCRIPT_ROOT=$(cd "${0%/*}" && echo "$PWD")
cd "$SCRIPT_ROOT"

trap "exit 0" TERM
trap "kill 0" EXIT
export TOP_PID=$$

#variables
search_regex=""
outputfile="./toraddress"
keysize="1024"
device="0"
threads="4"
extra_options=""
loops="0"


opts=$(getopt -o r:o:k:d:e: -l regex:,output:,keysize:,device:,extra-options: -- "$@")
eval set -- "${opts}"
for i; do
	case "$i" in
		-r) search_regex="$2"; shift; shift;;
		--regex) search_regex="$2"; shift; shift;;
		-o) outputfile="$2"; shift; shift;;
		--output) outputfile="$2"; shift; shift;;
		-k) keysize="$2"; shift; shift;;
		--keysize) keysize="$2"; shift; shift;;
		-d) device="$2"; shift; shift;;
		--device) device="$2"; shift; shift;;
		-e) extra_options="$2"; shift; shift;;
		--extra-options) extra_options="$2"; shift; shift;;
		--) shift; break;
	esac
done


run_scallion() {
	mono ./scallion/bin/Debug/scallion.exe "${extra_options}" -k "${keysize}" -o "${outputfile}" -d "${device}" "${search_regex}"
}

thread() {
	while true; do
		if test -e "${outputfile}"; then
			echo "#$1 is DONE!" >&2
			break
		else
			echo "start #$1" >&2
			run_scallion >/dev/null 2>&1
			echo "stop #$1" >&2
		fi
	done
}

if test -e "${outputfile}"; then
	c=0
	while true; do
		if test -e "${outputfile}${c}"; then c=$((c+1));else break; fi
	done
	outputfile="${outputfile}${c}"
fi

while test $threads -gt $loops; do
	((loops++))
	thread $loops && kill -s TERM $TOP_PID &
done

wait
exit 0
