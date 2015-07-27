for code in {0..7}; do declare -gx "COLOR_${code}=$( printf "\x1B[3${code}m"; )"; done
for code in {0..7}; do declare -gx "COLOR_BG_${code}=$( printf "\x1B[4${code}m"; )"; done
declare -gx "COLOR_RESET=$( printf "\x1B[0m"; )"
