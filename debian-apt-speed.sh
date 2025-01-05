#!/usr/bin/env bash

set -Euo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

err() {
  local msg=$1
  local code=${2-1}
  msg "${RED}${1}${NOFORMAT}"
  if [ "${code}" != 0 ]; then
    exit "$code"
  fi
}

die() {
  local msg=$1
  local code=${2-1}
  msg "$msg"
  exit "$code"
}

dependency_check() {
  local MISSING_DEPENDENCY=false;
  for comm in "$@"
  do
      command -v "$comm" >/dev/null 2>&1 || { err >&2 "'$comm' is required to be installed." 0; MISSING_DEPENDENCY=true; }
  done

  if [ "$MISSING_DEPENDENCY" = true ]; then
      err "Aborting."
  fi
}

setup_colors

if [ "$(uname -s)" != "Linux" ]; then
    err "Platform not supported. Must be run on Linux. Aborting." 2
fi

dependency_check "curl" "grep" "bc" "ping" "tail" "awk" "cut" "sort" "head"

HTML_MIRRORS=$(curl -sL https://www.debian.org/mirror/list-full)
readarray -t MIRRORS < <(echo "$HTML_MIRRORS" | grep -s -P "Packages over HTTP: <tt><a " | grep -s -o -P "https?://[^\"<]+/")

if [ -z "${MIRRORS}" ] || [[ ! "${MIRRORS[0]}" =~ ^https?:// ]]; then
    err "Could not fetch mirror list."
fi

NUM_MIRRORS=${#MIRRORS[@]}

declare -A RESULT

echo
msg "Testing mirrors for speed..."
echo
for i in "${!MIRRORS[@]}"; do
    MIRROR_NUM=$((i+1))
    MIRROR=${MIRRORS[$i]}

    # Download the first 102 400 bytes with 2 second timeout
    SPEED_BPS=$(curl --max-time 2 -r 0-102400 -s -w %{speed_download} -o /dev/null "${MIRROR}/ls-lR.gz")
    SPEED_KBPS=$(echo "$SPEED_BPS / 1024" | bc)

    LATENCY_URL=$(echo ${MIRROR} | awk -F[/:] '{print $4}')
    LATENCY=$(ping -q -c 1 -W 1 $LATENCY_URL | tail -1 | awk '{print $4}' | cut -d '/' -f 2)

    msg "[$MIRROR_NUM/$NUM_MIRRORS] ${MIRROR} --> $SPEED_KBPS KB/s - $LATENCY ms"

    RESULT["${MIRROR}"]="$SPEED_KBPS $LATENCY"
done

# Sort mirrors by speed and get the top 5
echo
msg "Top 5 fastest mirrors"
echo
for MIRROR in "${!RESULT[@]}"; do
    echo "$MIRROR ${RESULT[$MIRROR]}"
done | sort -rn -k2 | head -5