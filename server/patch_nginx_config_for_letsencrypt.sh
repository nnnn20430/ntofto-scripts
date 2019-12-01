#!/bin/bash

declare -r SCRIPT_ROOT="$(cd "${0%/*}" 2>/dev/null; echo "$PWD")"
cd "$SCRIPT_ROOT"

#variables
NGINX_BINARY=""
NGINX_PREFIX=""
NGINX_CONFIG=""
WEBROOT="/etc/letsencrypt/webrootauth"

opts=$(getopt -o b:p:c:w: -l binary:,prefix:,config:,webroot-path: -- "$@")
eval set -- "${opts}"
for i; do
	case "$i" in
		-b) NGINX_BINARY="$2"; shift; shift;;
		--binary) NGINX_BINARY="$2"; shift; shift;;
		-p) NGINX_PREFIX=$2; shift; shift;;
		--prefix) background=$2; shift; shift;;
		-c) NGINX_CONFIG=$2; shift; shift;;
		--config) NGINX_CONFIG=$2; shift; shift;;
		-w) WEBROOT=$2; shift; shift;;
		--webroot-path) WEBROOT=$2; shift; shift;;
		--) shift; break;
	esac
done

echo "$(<${NGINX_CONFIG})" | sed -r "\
s|^(\s)*server.?\{\
|\
server {\
rewrite \"\^\(\/\.well-known\/acme-challenge\/\.\*\)\$\" \"\$1\" last; \
location \/\.well-known\/acme-challenge {\
alias $(\
echo "$WEBROOT" | sed -e 's/\([[\/.*]\|\]\)/\\&/g'\
)\/\.well-known\/acme-challenge; \
location ~ \/\.well-known\/acme-challenge\/\(\.\*\) {\
add_header Content-Type application\/jose\+json;\
}\
}\
|" >./letsencrypt_nginx.conf
mount --bind ./letsencrypt_nginx.conf "${NGINX_CONFIG}"
"${NGINX_BINARY}" -p "${NGINX_PREFIX}" -s reload
umount -fl "${NGINX_CONFIG}"
rm -f ./letsencrypt_nginx.conf
