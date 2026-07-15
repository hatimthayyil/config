#!/bin/sh
set -eu

# Niks3 accepts signing keys only by path. The Worker provides this value as a
# secret environment variable, so materialize it in the container's ephemeral
# filesystem immediately before execing the server.
umask 077
sign_key_path=/tmp/niks3-signing-key
printf '%s\n' "$NIKS3_SIGN_KEY" > "$sign_key_path"
export NIKS3_SIGN_KEY_PATHS="$sign_key_path"
unset NIKS3_SIGN_KEY

exec /usr/local/bin/niks3-server
