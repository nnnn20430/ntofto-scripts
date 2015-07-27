#!/bin/zsh
export TERM=xterm-256color
for code in {0..255}; do echo -e "\e[38;05;${code}m $code: Test"; done; printf "\x1B[0m"
