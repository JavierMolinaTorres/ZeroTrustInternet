#!/bin/bash
# Script to report ddos-deflate banned IPs
# ddos-deflate does not keep date for each banned ip. ZTI only accepts that you ban any ip a maximun of 24 hours
# Configuration
TOOL="ddos-deflate"
BANLIST="/usr/local/ddos/banlist.txt"
TOKEN="MY_SUPER_SECRET_TOKEN"
POST_URL="https://my.server.com/api/ddosdeflate-report"
SEND_POST=0

# Temporal files
JSON_FILE="/tmp/ddosdeflate_report.json"

echo "Collecting IPs from $TOOL banlist..."

# Check if banlist exists
if [ ! -f "$BANLIST" ]; then
    echo "❌ Banlist file $BANLIST not found!"
    exit 1
fi

# Read IPs
BANNED_IPS=$(cat "$BANLIST")

# Build JSON
echo "{" > "$JSON_FILE"
echo '  "tool": "'"$TOOL"'",' >> "$JSON_FILE"
echo '  "report_generated": "'"$(date '+%Y-%m-%d %H:%M:%S')"'",' >> "$JSON_FILE"
echo '  "banned_ips": [' >> "$JSON_FILE"

FIRST=1
for IP in $BANNED_IPS; do
    [ $FIRST -eq 0 ] && echo "," >> "$JSON_FILE"
    echo '    { "ip": "'"$IP"'" }' >> "$JSON_FILE"
    FIRST=0
done

echo "  ]" >> "$JSON_FILE"
echo "}" >> "$JSON_FILE"

echo "JSON generated in $JSON_FILE:"
cat "$JSON_FILE"

# Prepare (and in case, send) the POST
echo
echo "Preparing POST to $POST_URL"

if [ "$SEND_POST" -eq 1 ]; then
  curl -X POST "$POST_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $TOKEN" \
    -d @"$JSON_FILE"
  echo "✅ POST sent."
else
  echo "⚠️ POST deactivated in configuration (SEND_POST=0)."
fi
