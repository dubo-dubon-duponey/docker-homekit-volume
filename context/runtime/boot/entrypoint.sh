#!/usr/bin/env bash
set -o errexit -o errtrace -o functrace -o nounset -o pipefail

ALSA_CARD=${ALSA_CARD:-}
ALSA_DEVICE=${ALSA_DEVICE:-}
HOMEKIT_NAME=${HOMEKIT_NAME:-}
HOMEKIT_MANUFACTURER=${HOMEKIT_MANUFACTURER:-}
HOMEKIT_SERIAL=${HOMEKIT_SERIAL:-}
HOMEKIT_MODEL=${HOMEKIT_MODEL:-}
HOMEKIT_VERSION=${HOMEKIT_VERSION:-}
HOMEKIT_PIN=${HOMEKIT_PIN:-}
PORT=${PORT:-10042}

# Ensure the data folder is writable
[ -w /data ] || {
  printf >&2 "/data is not writable. Check your mount permissions.\n"
  exit 1
}

args=()

[ ! "$ALSA_CARD" ]              || args+=(--card          "$ALSA_CARD")
[ ! "$ALSA_DEVICE" ]            || args+=(--device        "$ALSA_DEVICE")
[ ! "$HOMEKIT_NAME" ]           || args+=(--name          "$HOMEKIT_NAME")
[ ! "$HOMEKIT_MANUFACTURER" ]   || args+=(--manufacturer  "$HOMEKIT_MANUFACTURER")
[ ! "$HOMEKIT_SERIAL" ]         || args+=(--serial        "$HOMEKIT_SERIAL")
[ ! "$HOMEKIT_MODEL" ]          || args+=(--model         "$HOMEKIT_MODEL")
[ ! "$HOMEKIT_VERSION" ]        || args+=(--version       "$HOMEKIT_VERSION")
[ ! "$HOMEKIT_PIN" ]            || args+=(--pin           "$HOMEKIT_PIN")
[ ! "$PORT" ]                   || args+=(--port          "$PORT")

# Run once configured
exec homekit-alsa register --data-path=/data/dubo-amp "${args[@]}" "$@"
