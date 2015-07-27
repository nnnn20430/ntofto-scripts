#!/bin/bash

#command -v apt-mirror >/dev/null 2>&1 || { echo >&2 "apt-mirror is not installed."; sudo apt-get install apt-mirror; }

generate_random_string()
{
	cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1
}


create_temp_mirror_config()
{
	if test -e "$1";then rm "$1";fi
	NEWLINE=$'\n'
	echo -n "############# config ##################${NEWLINE}#${NEWLINE}set base_path ${PWD}${NEWLINE}set postmirror_script \$var_path/clean.sh${NEWLINE}set nthreads 20${NEWLINE}set _tilde 0${NEWLINE}#${NEWLINE}############# end config ##############${NEWLINE}${NEWLINE}" >>$1
	IFS="$NEWLINE"
	repobaseurls=""
	for repolink in `grep -x 'deb .*' ./mirror.list`
	do
		repolink=$(echo -n $repolink | sed "s|deb ||")
		repobaseurls="$(echo -n $repolink | sed -r "s|([^ ]*)( .*)|\1|" | { read link; link=$link; echo -n "$repobaseurls" | sed 's|'"clean ${link}"'||g' | { read -rd '' repobaseurls; echo -n "${repobaseurls}${NEWLINE}clean ${link}"; }; })"
		echo -n "deb ${repolink}${NEWLINE}deb-i386 ${repolink}${NEWLINE}deb-src ${repolink}${NEWLINE}" >>$1
	done
	echo -n "$(repobaseurls=${repobaseurls//"${NEWLINE}${NEWLINE}"/};echo "${NEWLINE}${repobaseurls}")" >>$1
}

tmp_id=$(generate_random_string)
create_temp_mirror_config "/tmp/$tmp_id"
sudo ./apt-mirror-bin "/tmp/$tmp_id"
rm "/tmp/$tmp_id"
