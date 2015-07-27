#!/bin/zsh
for code in {0..7}; do printf "\x1B[3${code}m $code: Test\n"; done
printf "\x1B[0m"
