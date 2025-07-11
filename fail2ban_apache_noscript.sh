# Detects banned ips that try to access non-existing requests like /admin or /login to apache and sends a JSON to a server for Extended Distributed NAC (EDNAC) within ZTI project.Use only https connections for POST delivery of JSON.
#!/bin/bash
# Configuration
JAIL="apache-noscript"                               # Jail to inspect
SINCE_DATE=$(date --date='-1 day' '+%Y-%m-%d %H:%M:%S')  # It collects the last 24h
TOKEN="MY_SUPER_SECRET_TOKEN"           # Auth token, to be read by the server (if exists). If token is loaded from file, use for instance TOKEN=$(cat /etc/fail2ban_report_token)
POST_URL="https://my.server.com/api/fail2ban-report"  # URL of the server
SEND_POST=0                              # ⚠️ 0 = do not send, 1 = send by POST method

# Temporal files
CURRENT_BANNED="/tmp/current_banned_ips.txt"
RECENT_BANNED="/tmp/recent_banned_ips.txt"
JSON_FILE="/tmp/fail2ban_report.json"

echo "Collecting IPs from jail '$JAIL' since $SINCE_DATE..."

# List current banned IPs (not filtered by date)
fail2ban-client status "$JAIL" | grep 'Banned IP list' | awk -F': ' '{print $2}' | tr ' ' '\n' > "$CURRENT_BANNED"

# Get banned IPs in the last 24h using logs
zgrep "$JAIL" /var/log/fail2ban.log* | grep 'Ban' | awk -v since="$SINCE_DATE" '
{
  datetime = substr($1, 2, 19);
  if (datetime >= since) print datetime " " $NF;
}' | sort | uniq > "$RECENT_BANNED"

# Built JSON
echo "{" > "$JSON_FILE"
echo '  "jail": "'"$JAIL"'",' >> "$JSON_FILE"
echo '  "since": "'"$SINCE_DATE"'",' >> "$JSON_FILE"
echo '  "report_generated": "'"$(date '+%Y-%m-%d %H:%M:%S')"'",' >> "$JSON_FILE"
echo '  "banned_ips": [' >> "$JSON_FILE"

FIRST=1
while read -r line; do
    DATE=$(echo "$line" | awk '{print $1, $2}')
    IP=$(echo "$line" | awk '{print $3}')
    [ $FIRST -eq 0 ] && echo "," >> "$JSON_FILE"
    echo '    { "ip": "'"$IP"'", "banned_at": "'"$DATE"'" }' >> "$JSON_FILE"
    FIRST=0
done < "$RECENT_BANNED"

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
