#!/bin/bash
read -p "Subject: " subject

c=0
while true; do
	if test -e "./${subject}_${c}.odt";then c=$((c+1));else break; fi
done
cp "./data/TEMPLATE.odt" "./${subject}_${c}.odt"

bash -c " nohup libreoffice --writer \"./${subject}_${c}.odt\" >/dev/null 2>&1 &" 0<&- &>/dev/null 2>&1; disown -a; sleep 0.1

