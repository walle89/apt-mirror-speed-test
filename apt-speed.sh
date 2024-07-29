#!/bin/bash

COUNTY_CODE=${1^^}

# Country code from GeoIP if not provided
if [ -z "${COUNTY_CODE}" ]; then
    COUNTY_CODE=$(curl -sL 'https://ipinfo.io/country')
fi

if [ "${#COUNTY_CODE}" -ne 2 ]; then
    echo "Invalid country code. Aborting."
    exit 1
fi

mapfile -t MIRRORS < <(curl -sL http://mirrors.ubuntu.com/${COUNTY_CODE}.txt)
NUM_MIRRORS=${#MIRRORS[@]}

declare -A RESULT

echo
echo "Testing ${COUNTY_CODE} mirrors for speed..."
echo
for i in "${!MIRRORS[@]}"; do
    MIRROR_NUM=$((i+1))

    # Download the first 102 400 bytes with 2 second timeout
    SPEED_BPS=$(curl --max-time 2 -r 0-102400 -s -w %{speed_download} -o /dev/null "${MIRRORS[$i]}/ls-lR.gz")
    SPEED_KBPS=$(echo "$SPEED_BPS / 1024" | bc)

    LATENCY_URL=$(echo ${MIRRORS[$i]} | awk -F[/:] '{print $4}')
    LATENCY=$(ping -q -c 1 -W 1 $LATENCY_URL | tail -1 | awk '{print $4}' | cut -d '/' -f 2)

    echo "[$MIRROR_NUM/$NUM_MIRRORS] ${MIRRORS[$i]} --> $SPEED_KBPS KB/s - $LATENCY ms"

    RESULT["${MIRRORS[$i]}"]="$SPEED_KBPS $LATENCY"
done

# Sort mirrors by speed and get the top 5
echo
echo "Top 5 fastest mirrors"
echo
for MIRROR in "${!RESULT[@]}"; do
    echo "$MIRROR ${RESULT[$MIRROR]}"
done | sort -rn -k2 | head -5