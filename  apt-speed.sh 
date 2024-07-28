!/bin/bash

COUNTY_CODE=$1

# Country code from GeoIP
if [ -z "${COUNTY_CODE}" ]; then
    COUNTY_CODE=$(curl -s 'https://ipinfo.io/country')
fi

if [ "${#COUNTY_CODE}" -ne 2 ]; then
    echo "Invalid country code."
    exit 1
fi

# Read the list of mirrors
mapfile -t mirrors < <(curl -q http://mirrors.ubuntu.com/${COUNTY_CODE}.txt)
total_mirrors=${#mirrors[@]}

declare -A speeds

echo "Testing mirrors for speed..."

# Test each mirror with a 2-second timeout
for i in "${!mirrors[@]}"; do
    seq_num=$((i+1))

    speed_bps=$(curl --max-time 2 -r 0-102400 -s -w %{speed_download} -o /dev/null "${mirrors[$i]}/ls-lR.gz")
    speed_kbps=$(echo "$speed_bps / 1024" | bc)

    speeds["${mirrors[$i]}"]=$speed_kbps

    echo "[$seq_num/$total_mirrors] ${mirrors[$i]} --> $speed_kbps KB/s"
done

# Sort mirrors by speed and get the top 5
echo "Top 5 fastest mirrors:"
for mirror in "${!speeds[@]}"; do
    echo "$mirror ${speeds[$mirror]}"
done | sort -rn -k2 | head -5