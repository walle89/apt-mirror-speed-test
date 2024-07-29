#!/bin/bash

HTML_MIRRORS=$(curl -sL https://www.debian.org/mirror/list-full)
readarray -t MIRRORS < <(echo "$HTML_MIRRORS" | grep -s -P "Packages over HTTP: <tt><a " | grep -s -o -P "https?://[^\"<]+/")

if [ -z "${MIRRORS}" ] || [[ ! "${MIRRORS[0]}" =~ ^https?:// ]]; then
    echo "Could not fetch mirror list."
    exit 1
fi

NUM_MIRRORS=${#MIRRORS[@]}

declare -A RESULT

echo
echo "Testing mirrors for speed..."
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