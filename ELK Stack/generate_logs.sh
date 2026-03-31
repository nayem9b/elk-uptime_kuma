#!/bin/bash
# =============================================================================
#  generate_logs.sh — Generate dummy logs matched to logstash.conf parsing
#  Run from project root: bash generate_logs.sh
# =============================================================================

DATA_DIR="$(pwd)/data"
mkdir -p "$DATA_DIR"

# ── Timestamp helpers (all use NOW so Kibana shows them immediately) ─────────
# Nginx format:   31/Mar/2026:10:00:01 +0000
# Syslog format:  Mar 31 10:00:01          (no year — Logstash infers current year)
# JSON format:    2026-03-31T10:00:00Z
# Plain format:   2026-03-31 10:00:00

NOW=$(date -u)
DATE_JSON=$(date -u +"%Y-%m-%dT%H:%M:%SZ")             # 2026-03-31T10:00:00Z
DATE_PLAIN=$(date -u +"%Y-%m-%d %H:%M:%S")             # 2026-03-31 10:00:00
DATE_NGINX=$(date -u +"%d/%b/%Y:%H:%M:%S +0000")       # 31/Mar/2026:10:00:01 +0000
DATE_SYSLOG=$(date -u +"%-b %e %H:%M:%S")              # Mar 31 10:00:01  (%-b = no zero-pad month, %e = space-padded day)

# Generate timestamps offset by N seconds from now
ts_json()   { date -u -d "$1 seconds" +"%Y-%m-%dT%H:%M:%SZ"      2>/dev/null || date -u -v+"$1"S +"%Y-%m-%dT%H:%M:%SZ"; }
ts_plain()  { date -u -d "$1 seconds" +"%Y-%m-%d %H:%M:%S"        2>/dev/null || date -u -v+"$1"S +"%Y-%m-%d %H:%M:%S"; }
ts_nginx()  { date -u -d "$1 seconds" +"%d/%b/%Y:%H:%M:%S +0000"  2>/dev/null || date -u -v+"$1"S +"%d/%b/%Y:%H:%M:%S +0000"; }
ts_syslog() { date -u -d "$1 seconds" +"%-b %e %H:%M:%S"          2>/dev/null || date -u -v+"$1"S +"%-b %e %H:%M:%S"; }

echo "📁 Writing dummy logs to $DATA_DIR ..."
echo "🕐 Base timestamp: $NOW"

# ---------------------------------------------------------------------------
# 1. nginx_access.log — format: dd/MMM/yyyy:HH:mm:ss Z
#    Logstash date filter: match => ["time_local", "dd/MMM/yyyy:HH:mm:ss Z"]
# ---------------------------------------------------------------------------
cat > "$DATA_DIR/nginx_access.log" << EOF
192.168.1.10 - alice [$(ts_nginx 0)] "GET /index.html HTTP/1.1" 200 1024 "-" "Mozilla/5.0 (Windows NT 10.0)"
203.0.113.45 - - [$(ts_nginx -30)] "POST /api/login HTTP/1.1" 200 256 "https://example.com" "curl/7.68.0"
198.51.100.7 - bob [$(ts_nginx -60)] "GET /dashboard HTTP/1.1" 301 0 "-" "Mozilla/5.0 (Macintosh)"
10.0.0.5 - - [$(ts_nginx -90)] "GET /api/users HTTP/1.1" 401 89 "-" "PostmanRuntime/7.29"
172.16.0.22 - charlie [$(ts_nginx -120)] "DELETE /api/resource/42 HTTP/1.1" 403 112 "-" "axios/1.3.0"
192.168.1.10 - alice [$(ts_nginx -150)] "GET /static/app.js HTTP/1.1" 200 51200 "https://example.com/index.html" "Mozilla/5.0"
203.0.113.99 - - [$(ts_nginx -180)] "GET /nonexistent HTTP/1.1" 404 162 "-" "Mozilla/5.0"
10.0.0.1 - admin [$(ts_nginx -210)] "POST /api/data HTTP/1.1" 500 300 "-" "curl/7.68.0"
198.51.100.7 - bob [$(ts_nginx -240)] "GET /health HTTP/1.1" 200 18 "-" "kube-probe/1.27"
172.16.0.99 - - [$(ts_nginx -270)] "PUT /api/settings HTTP/1.1" 200 512 "https://example.com" "Mozilla/5.0 (Linux)"
192.168.1.55 - dave [$(ts_nginx -300)] "GET /api/stream HTTP/1.1" 200 204800 "-" "VLC/3.0.18"
203.0.113.45 - - [$(ts_nginx -330)] "GET /favicon.ico HTTP/1.1" 304 0 "-" "Mozilla/5.0"
10.0.0.5 - - [$(ts_nginx -360)] "POST /api/login HTTP/1.1" 429 45 "-" "python-requests/2.28"
EOF

# ---------------------------------------------------------------------------
# 2. app.log — JSON lines
#    Logstash: json { source => "message" } then rename [json_parsed][timestamp] => @timestamp
#    Key: field must be "timestamp" (not "ts" or "@timestamp")
# ---------------------------------------------------------------------------
cat > "$DATA_DIR/app.log" << EOF
{"timestamp":"$(ts_json 0)","level":"info","service":"auth-service","msg":"Server started","port":8080}
{"timestamp":"$(ts_json -30)","level":"info","service":"auth-service","msg":"User login successful","user_id":"u_001","ip":"192.168.1.10"}
{"timestamp":"$(ts_json -60)","level":"warn","service":"auth-service","msg":"Failed login attempt","user_id":"u_002","ip":"203.0.113.45","attempts":3}
{"timestamp":"$(ts_json -90)","level":"info","service":"api-gateway","msg":"Request received","method":"GET","path":"/api/users","latency_ms":12}
{"timestamp":"$(ts_json -120)","level":"error","service":"db-service","msg":"Connection timeout","host":"postgres:5432","retry":1}
{"timestamp":"$(ts_json -150)","level":"error","service":"db-service","msg":"Connection timeout","host":"postgres:5432","retry":2}
{"timestamp":"$(ts_json -180)","level":"info","service":"db-service","msg":"Connection restored","host":"postgres:5432"}
{"timestamp":"$(ts_json -210)","level":"info","service":"api-gateway","msg":"Request received","method":"POST","path":"/api/data","latency_ms":45}
{"timestamp":"$(ts_json -240)","level":"warn","service":"cache-service","msg":"Cache miss rate high","rate":0.87,"threshold":0.5}
{"timestamp":"$(ts_json -270)","level":"info","service":"worker","msg":"Job completed","job_id":"j_9921","duration_ms":1200}
{"timestamp":"$(ts_json -300)","level":"debug","service":"worker","msg":"Processing queue","queue_depth":14}
{"timestamp":"$(ts_json -330)","level":"error","service":"payment-service","msg":"Payment gateway unreachable","gateway":"stripe","status_code":503}
{"timestamp":"$(ts_json -360)","level":"critical","service":"payment-service","msg":"Payment processing halted","reason":"gateway_down"}
{"timestamp":"$(ts_json -390)","level":"info","service":"payment-service","msg":"Payment gateway recovered","gateway":"stripe"}
{"timestamp":"$(ts_json -420)","level":"warn","service":"api-gateway","msg":"Rate limit approaching","user_id":"u_005","requests":95,"limit":100}
{"timestamp":"$(ts_json -450)","level":"error","service":"storage-service","msg":"Disk usage critical","used_pct":92,"mount":"/var/data"}
{"timestamp":"$(ts_json -480)","level":"info","service":"api-gateway","msg":"Health check passed","uptime_s":600}
EOF

# ---------------------------------------------------------------------------
# 3. syslog.log — Syslog format WITHOUT year
#    Logstash date filter: match => ["syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss"]
#    IMPORTANT: no year in the timestamp — Logstash infers the current year
# ---------------------------------------------------------------------------
cat > "$DATA_DIR/syslog.log" << EOF
$(ts_syslog 0) webserver01 sshd[1234]: Accepted publickey for deploy from 192.168.1.5 port 54321 ssh2
$(ts_syslog -30) webserver01 sudo[5678]: alice : TTY=pts/0 ; PWD=/var/www ; USER=root ; COMMAND=/bin/systemctl restart nginx
$(ts_syslog -60) webserver01 nginx[910]: Starting nginx: nginx.
$(ts_syslog -90) webserver01 kernel: OUT OF MEMORY: Kill process 3321 (java) score 870 or sacrifice child
$(ts_syslog -120) webserver01 sshd[2345]: Failed password for root from 203.0.113.99 port 22 ssh2
$(ts_syslog -150) webserver01 sshd[2345]: Failed password for root from 203.0.113.99 port 22 ssh2
$(ts_syslog -180) webserver01 sshd[2345]: Failed password for root from 203.0.113.99 port 22 ssh2
$(ts_syslog -210) webserver01 sshd[2346]: Disconnecting invalid user root 203.0.113.99 port 22
$(ts_syslog -240) webserver01 cron[456]: (root) CMD (/usr/bin/certbot renew --quiet)
$(ts_syslog -270) webserver01 dockerd[789]: time="2026-01-01T10:04:10" level=warning msg="container failed to exit within 10 seconds"
$(ts_syslog -300) webserver01 systemd[1]: Started Daily apt upgrade and clean activities.
$(ts_syslog -330) webserver01 kernel: eth0: renamed from veth3a2b1c
$(ts_syslog -360) webserver01 postfix/smtp[6543]: connect to mail.example.com[93.184.216.34]:25: Connection timed out
$(ts_syslog -390) webserver01 sshd[7890]: Accepted password for bob from 10.0.0.15 port 43210 ssh2
$(ts_syslog -420) webserver01 ufw[999]: [UFW BLOCK] IN=eth0 OUT= SRC=45.33.32.156 DST=203.0.113.1 PROTO=TCP DPT=3306
$(ts_syslog -450) webserver01 sshd[1234]: Received disconnect from 192.168.1.5 port 54321:11: disconnected by user
EOF

# ---------------------------------------------------------------------------
# 4. plain.log — Plain text with log level keywords
#    Logstash grok: "(?i)(?<log_level>DEBUG|INFO|WARN(?:ING)?|ERROR|CRITICAL|FATAL)"
# ---------------------------------------------------------------------------
cat > "$DATA_DIR/plain.log" << EOF
$(ts_plain 0) INFO  Application starting up...
$(ts_plain -30) INFO  Loading configuration from /etc/app/config.yaml
$(ts_plain -60) INFO  Database connection pool initialized (size=10)
$(ts_plain -90) INFO  Message queue connected: amqp://rabbitmq:5672
$(ts_plain -120) INFO  HTTP server listening on :8080
$(ts_plain -150) DEBUG Incoming request: GET /api/status
$(ts_plain -180) DEBUG Cache lookup: HIT for key=status_v2
$(ts_plain -210) WARN  Memory usage above 75%: 3.1GB / 4GB
$(ts_plain -240) INFO  Background job scheduler started, next run in 60s
$(ts_plain -270) DEBUG Incoming request: POST /api/ingest
$(ts_plain -300) INFO  Ingested 1500 records in 230ms
$(ts_plain -330) ERROR Failed to send email notification: SMTP connection refused (host=smtp.example.com:587)
$(ts_plain -360) WARN  Retrying email send in 30s (attempt 1/3)
$(ts_plain -390) WARN  Retrying email send in 30s (attempt 2/3)
$(ts_plain -420) ERROR Email notification failed after 3 attempts. Dropping message.
$(ts_plain -450) INFO  Scheduled cleanup: removed 412 expired sessions
$(ts_plain -480) WARN  Slow query detected (450ms): SELECT * FROM events WHERE user_id=?
$(ts_plain -510) DEBUG Incoming request: GET /metrics
$(ts_plain -540) INFO  Health check: OK (uptime=540s, memory=3.1GB, cpu=12%)
$(ts_plain -570) FATAL Unhandled exception in worker thread: NullPointerException at line 342
EOF

echo ""
echo "✅ Done! Files written:"
ls -lh "$DATA_DIR"
echo ""
echo "👉 Restart Filebeat to ship the new files:"
echo "   docker restart filebeat"
echo ""
echo "👉 In Kibana → Discover, set time range to: Last 1 hour"