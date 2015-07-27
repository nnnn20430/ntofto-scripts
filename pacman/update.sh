#!/bin/bash

#variables
targetDirectory="./data/repo/ftp.archlinux.org/"
background=false

opts=$(getopt -o d:b -l dir:,background -- "$@")
eval set -- "${opts}"
for i; do
    case "$i" in
        -d) targetDirectory="$2"; shift; shift;;
        -b) background=true; shift;;
        --) shift; break;
    esac
done

if test "${background}" = true; then
	nohup rsync -rtvpl -P rsync://archlinux.polymorf.fr/archlinux/ ${targetDirectory} >/dev/null 2>&1 &
	disown -ah >/dev/null 2>&1
	exit 0
else
	rsync -rtvpl -P rsync://archlinux.polymorf.fr/archlinux/ ${targetDirectory}
fi
