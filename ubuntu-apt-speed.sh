#!/usr/bin/env bash

set -Euo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

usage() {
  cat <<EOF
Usage: curl -sL https://raw.githubusercontent.com/walle89/apt-mirror-speed-test/main/ubuntu-apt-speed.sh | bash [-s ARG1]

Speed and latency testing of Ubuntu mirrors.

Manual testing of specific country mirrors:
- Add an Alpha-2 country code as ARG1 to manually test a specific country mirror.
- List of available country codes is available at: http://mirrors.ubuntu.com/.

Testing of Launchpad Mirrors:
- If ARG1 is set to "ALL," it will test all mirrors listed at: https://launchpad.net/ubuntu/+archivemirrors.
EOF
  exit
}

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
  if [ "${code}" = 2 ]; then
    usage
  fi
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

# Internal caching vars
IPV4_SUPPORT=""
IPV6_SUPPORT=""

has_ipv4() {
  if [ -z "$IPV4_SUPPORT" ]; then
    IPV4_SUPPORT="false"
    if (ping -4 -c1 -W2 ipinfo.io >/dev/null 2>&1 || curl -4sm3 icanhazip.com >/dev/null 2>&1); then
      IPV4_SUPPORT="true"
    fi
  fi
  [ "$IPV4_SUPPORT" = "true" ]
}

has_ipv6() {
  if [ -z "$IPV6_SUPPORT" ]; then
    IPV6_SUPPORT="false"
    if (ping -6 -c1 -W2 v6.ipinfo.io >/dev/null 2>&1 || curl -6sm3 icanhazip.com >/dev/null 2>&1); then
      IPV6_SUPPORT="true"
    fi
  fi
  [ "$IPV6_SUPPORT" = "true" ]
}

setup_colors

if [ "$(uname -s)" != "Linux" ]; then
    err "Platform not supported. Must be run on Linux. Aborting." 2
fi
dependency_check "curl" "grep" "bc" "ping" "tail" "awk" "cut" "sort" "head"

COUNTY_CODE=${1-}

# Determine country code from GeoIP if not provided
if [ -z "${COUNTY_CODE}" ]; then
    if has_ipv4; then
        COUNTY_CODE=$(curl -4sL https://ipinfo.io/country)
    elif has_ipv6; then
        COUNTY_CODE=$(curl -6sL https://v6.ipinfo.io/country)
    else
        err "Could not determine country code. Check your network or add a country code manually as ARG1." 1
    fi
fi

if [ "${COUNTY_CODE}" == "ALL" ]; then
    HTML_MIRRORS=$(curl -sL https://launchpad.net/ubuntu/+archivemirrors)
    readarray -t MIRRORS < <(echo "$HTML_MIRRORS" | grep -s -P -B8 "statusUP" | grep -s -o -P "http://[^\"]*")
elif [ "${#COUNTY_CODE}" -eq 2 ]; then
    mapfile -t MIRRORS < <(curl -sL http://mirrors.ubuntu.com/${COUNTY_CODE}.txt)

    # Handle known IPv6 limitation with mirrors.ubuntu.com
    if [ "${#MIRRORS[@]}" -eq 0 ] && ! has_ipv4 && has_ipv6; then
        err "IPv4 is required for country-specific mirrors. Use 'ALL' as ARG1 to test all mirrors instead." 2
    fi
else
    err "Invalid country code '$(printf '%q' "${COUNTY_CODE:0:50}")'. Aborting." 1
fi

if [ "${#MIRRORS[@]}" -eq 0 ]; then
    err "Failed to fetch mirrors for '${COUNTY_CODE}'. Check your network or try another country code." 2
fi

# Abort for invalid URL. Will cover most types of error reposes
if ! [[ "${MIRRORS[0]}" =~ ^(ftp|http)s?:// ]]; then
    err "No mirrors found for '${COUNTY_CODE}'. Try another country code or use 'ALL'." 2
fi

NUM_MIRRORS=${#MIRRORS[@]}

declare -A RESULT

echo
msg "Testing $(printf '%q' "${COUNTY_CODE}") mirrors for speed..."
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