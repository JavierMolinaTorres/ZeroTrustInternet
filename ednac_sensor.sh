#!/bin/bash
# EDNAC Sensor is a lightweight security probe that inspects local logs (Apache, SSH, Fail2ban) and reports suspicious activity to the distributed EDNAC network.
# EDNAC Sensor can be considered a mini-siem
# Created by Javier Molina Torres

TOKEN="MY_SUPER_SECRET_TOKEN"   # change accordingly 
POST_URL="https://my.server.com/api/ednac-report" # url of the remote server that captures JSON send by POST method-
SEND_POST=0 # 0 = no send | 1 = send

JSON_FILE="/tmp/ednac_report.json"

# Thresholds
SSH_FAIL_THRESHOLD=3
APACHE_404_THRESHOLD=10
APACHE_FORBIDDEN_THRESHOLD=5

# Files
SSH_LOG="/var/log/auth.log"
FAIL2BAN_LOG="/var/log/fail2ban.log"
APACHE_ACCESS_LOG="/var/log/apache2/access.log"

echo "Building EDNAC report..."

echo "{" > "$JSON_FILE"
echo '  "date": "'"$(date '+%Y-%m-%d %H:%M:%S')"'",' >> "$JSON_FILE"
echo '  "suspicious_ips": [' >> "$JSON_FILE"

FIRST=1

### SSH FAILED LOGINS
echo "Analyzing SSH failed logins..."
grep 'Failed password' "$SSH_LOG" | awk '{print $(NF-3)}' | sort | uniq -c | awk -v th="$SSH_FAIL_THRESHOLD" '$1 >= th {print $2}' | while read -r IP; do
    [ $FIRST -eq 0 ] && echo "," >> "$JSON_FILE"
    echo '    { "ip": "'"$IP"'", "source": "ssh", "reason": "Repeated failed logins" }' >> "$JSON_FILE"
    FIRST=0
done

### FAIL2BAN BANS
echo "Analyzing Fail2ban bans..."
grep 'Ban' "$FAIL2BAN_LOG" | awk '{print $NF}' | sort | uniq | while read -r IP; do
    [ $FIRST -eq 0 ] && echo "," >> "$JSON_FILE"
    echo '    { "ip": "'"$IP"'", "source": "fail2ban", "reason": "Banned by fail2ban" }' >> "$JSON_FILE"
    FIRST=0
done

### APACHE ANALYSIS
echo "Analyzing Apache logs..."
# Many 404
grep ' 404 ' "$APACHE_ACCESS_LOG" | awk '{print $1}' | sort | uniq -c | awk -v th="$APACHE_404_THRESHOLD" '$1 >= th {print $2}' | while read -r IP; do
    [ $FIRST -eq 0 ] && echo "," >> "$JSON_FILE"
    echo '    { "ip": "'"$IP"'", "source": "apache", "reason": "High 404 errors" }' >> "$JSON_FILE"
    FIRST=0
done

# Many 403
grep ' 403 ' "$APACHE_ACCESS_LOG" | awk '{print $1}' | sort | uniq -c | awk -v th="$APACHE_FORBIDDEN_THRESHOLD" '$1 >= th {print $2}' | while read -r IP; do
    [ $FIRST -eq 0 ] && echo "," >> "$JSON_FILE"
    echo '    { "ip": "'"$IP"'", "source": "apache", "reason": "High 403 errors" }' >> "$JSON_FILE"
    FIRST=0
done

# Suspicious URLs
grep -E '/(wp-login\.php|admin|phpmyadmin)' "$APACHE_ACCESS_LOG" | awk '{print $1}' | sort | uniq | while read -r IP; do
    [ $FIRST -eq 0 ] && echo "," >> "$JSON_FILE"
    echo '    { "ip": "'"$IP"'", "source": "apache", "reason": "Accessed sensitive URLs" }' >> "$JSON_FILE"
    FIRST=0
done

# Injection patterns
grep -Ei "(select.+from|union.+select|<script>|%27|%3C)" "$APACHE_ACCESS_LOG" | awk '{print $1}' | sort | uniq | while read -r IP; do
    [ $FIRST -eq 0 ] && echo "," >> "$JSON_FILE"
    echo '    { "ip": "'"$IP"'", "source": "apache", "reason": "Potential injection attempt" }' >> "$JSON_FILE"
    FIRST=0
done

echo "  ]" >> "$JSON_FILE"
echo "}" >> "$JSON_FILE"

echo "JSON generated in $JSON_FILE:"
cat "$JSON_FILE"

if [ "$SEND_POST" -eq 1 ]; then
    curl -X POST "$POST_URL" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $TOKEN" \
        -d @"$JSON_FILE"
    echo "✅ POST sent."
else
    echo "⚠️ POST deactivated (SEND_POST=0)."
fi
