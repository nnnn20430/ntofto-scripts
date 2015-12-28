#!/bin/bash

SUPER_REPO=$(git config --get remote.origin.url)
DEST_DIR="./out"
MODULE_LIST=$(echo -n "$(<./.gitmodules)" | awk -F '[ \t]' '$2 ~ /url/ { print($4); }')
export GIT_TERMINAL_PROMPT=0

cd $DEST_DIR

for repo in $MODULE_LIST; do
	git clone --bare $SUPER_REPO/$repo
done
