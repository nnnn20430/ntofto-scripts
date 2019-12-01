#!/bin/bash
declare -r SCRIPT_ROOT="$(cd "${0%/*}" 2>/dev/null; echo "$PWD")"
cd "$SCRIPT_ROOT"

#variables
version="1.8.8"
assetIndex="1.8"
CLASSPATH=$(find libraries -name \*.jar | tr '\n' ':')
username=""
launchArgs="java -Xmx1G -Xmn128M"
gameDir="${PWD}"
assetsDir="${PWD}/assets"
uuid=""
accessToken="0"
userType="legacy"
gameArgs=""

opts=$(getopt -o v:a:n:l:u: -l version:,asset-index:,username:,\
launch-arguments,uuid: -- "$@")
eval set -- "${opts}"
for i; do
	case "$i" in
		-v) version="$2"; shift; shift;;
		--version) version="$2"; shift; shift;;
		-a) assetIndex="$2"; shift; shift;;
		--asset-index) assetIndex="$2"; shift; shift;;
		-n) username="$2"; shift; shift;;
		--username) username="$2"; shift; shift;;
		-l) launchArgs="$2"; shift; shift;;
		--launch-arguments) launchArgs="$2"; shift; shift;;
		-u) uuid="$2"; shift; shift;;
		--uuid) uuid="$2"; shift; shift;;
		--) shift; break;
	esac
done

if test -z "${username}"; then
	echo -n 'nick: ' && read username
fi

run_minecraft() {
	${launchArgs} ${gameArgs}
}

CLASSPATH="${CLASSPATH}versions/${version}/${version}.jar"
gameArgs="${gameArgs} \
	-Djava.library.path=versions/${version}/${version}-natives \
	-cp ${CLASSPATH} \
	net.minecraft.client.main.Main \
	--username ${username} \
	--version ${version} \
	--gameDir ${gameDir} \
	--assetsDir ${assetsDir} \
	--assetIndex ${assetIndex} \
	--accessToken ${accessToken} \
	--userType legacy"

if test -n "${uuid}"; then
	gameArgs="${gameArgs} --uuid ${uuid}"
fi

run_minecraft &

wait
exit 0
