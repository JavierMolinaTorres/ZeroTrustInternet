#!/bin/bash
# This script reads the logs in Apache server and detects attacks agains wp-login of Wordpress. 
# --- Configuration ---
APACHE_LOG="/var/log/apache2/access.log"
THRESHOLD=5 # number of tries it detects from same ip as threshold (below that, it does not collect the data)

TOKEN="MY_SUPER_SECRET_TOKEN"
POST_URL="https://my.server.com/api/wp-login-report"
SEND_POST=0   # ⚠️ Set to 1 to activate POST sending

# --- Files ---
TMP_DIR="/tmp"
IP_COUNT_FILE="$TMP_DIR/wp_login_attempts.txt"
JSON_FILE="$TMP_DIR/wp_login_report.json"

echo "Analyzing WordPress login attempts in $APACHE_LOG..."

# --- Extract IPs making POST to wp-login.php ---
grep 'POST /wp-login.php' "$APACHE_LOG" | awk '{print $1}' | sort | uniq -c | sort -nr | awk -v th="$THRESHOLD" '$1 >= th {print $2, $1}' > "$IP_COUNT_FILE"

echo "Suspicious IPs (≥ $THRESHOLD attempts):"
cat "$IP_COUNT_FILE"

# --- Build JSON report ---
echo "{" > "$JSON_FILE"
echo '  "date": "'"$(date '+%Y-%m-%d %H:%M:%S')"'",' >> "$JSON_FILE"
echo '  "suspicious_wp_logins": [' >> "$JSON_FILE"

FIRST=1
while read -r COUNT IP; do
    [ -z "$IP" ] && continue  # Skip empty lines
    [ $FIRST -eq 0 ] && echo "," >> "$JSON_FILE"
    echo '    { "ip": "'"$IP"'", "attempts": '"$COUNT"' }' >> "$JSON_FILE"
    FIRST=0
done < "$IP_COUNT_FILE"

echo "  ]" >> "$JSON_FILE"
echo "}" >> "$JSON_FILE"

echo
echo "✅ JSON generated in $JSON_FILE:"
cat "$JSON_FILE"

# --- Send POST if enabled ---
echo
echo "Preparing POST to $POST_URL"

if [ "$SEND_POST" -eq 1 ]; then
    RESPONSE=$(curl -s -w "\nHTTP %{http_code}\n" -X POST "$POST_URL" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d @"$JSON_FILE")
    echo "$RESPONSE"
    echo "✅ POST sent."
else
    echo "⚠️ POST deactivated (SEND_POST=0)."
fi
