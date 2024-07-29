#!/bin/bash

COUNTY_CODE=${1^^}

# Country code from GeoIP if not provided
if [ -z "${COUNTY_CODE}" ]; then
    COUNTY_CODE=$(curl -sL 'https://ipinfo.io/country')
fi

if [ "${COUNTY_CODE}" == "ALL" ]; then
    HTML_MIRRORS=$(curl -sL https://launchpad.net/ubuntu/+archivemirrors)
    readarray -t MIRRORS < <(echo "$HTML_MIRRORS" | grep -s -P -B8 "statusUP" | grep -s -o -P "http://[^\"]*")
elif [ "${#COUNTY_CODE}" -eq 2 ]; then
    mapfile -t MIRRORS < <(curl -sL http://mirrors.ubuntu.com/${COUNTY_CODE}.txt)
else
    echo "Invalid country code. Aborting."
    exit 1
fi

if [ -z "${MIRRORS}" ]; then
    echo "Could not fetch mirror list."
    exit 1
fi

# Abort for invalid URL. Will cover most types of error reposes
if ! [[ "${MIRRORS[0]}" =~ ^(ftp|http)s?:// ]]; then
    echo "Mirror list not found for country code '${COUNTY_CODE}'."
    exit 1
fi

NUM_MIRRORS=${#MIRRORS[@]}

declare -A RESULT

echo
echo "Testing ${COUNTY_CODE} mirrors for speed..."
echo
for i in "${!MIRRORS[@]}"; do
    MIRROR_NUM=$((i+1))
    MIRROR=${MIRRORS[$i]}

    # Download the first 102 400 bytes with 2 second timeout
    SPEED_BPS=$(curl --max-time 2 -r 0-102400 -s -w %{speed_download} -o /dev/null "${MIRROR}/ls-lR.gz")
    SPEED_KBPS=$(echo "$SPEED_BPS / 1024" | bc)

    LATENCY_URL=$(echo ${MIRROR} | awk -F[/:] '{print $4}')
    LATENCY=$(ping -q -c 1 -W 1 $LATENCY_URL | tail -1 | awk '{print $4}' | cut -d '/' -f 2)

    echo "[$MIRROR_NUM/$NUM_MIRRORS] ${MIRROR} --> $SPEED_KBPS KB/s - $LATENCY ms"

    RESULT["${MIRROR}"]="$SPEED_KBPS $LATENCY"
done

# Sort mirrors by speed and get the top 5
echo
echo "Top 5 fastest mirrors"
echo
for MIRROR in "${!RESULT[@]}"; do
    echo "$MIRROR ${RESULT[$MIRROR]}"
done | sort -rn -k2 | head -5