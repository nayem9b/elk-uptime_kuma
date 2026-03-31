#!/bin/bash
# =============================================================================
#  generate_logs.sh — Create dummy log files in /data for ELK testing
#  Usage: sudo bash generate_logs.sh
# =============================================================================

DATA_DIR="/data"
mkdir -p "$DATA_DIR"

echo "📁 Writing dummy logs to $DATA_DIR ..."

# ---------------------------------------------------------------------------
# 1. nginx_access.log  — Nginx combined access log format
# ---------------------------------------------------------------------------
cat > "$DATA_DIR/nginx_access.log" << 'EOF'
192.168.1.10 - alice [01/Jan/2025:10:00:01 +0000] "GET /index.html HTTP/1.1" 200 1024 "-" "Mozilla/5.0 (Windows NT 10.0)"
203.0.113.45 - - [01/Jan/2025:10:00:05 +0000] "POST /api/login HTTP/1.1" 200 256 "https://example.com" "curl/7.68.0"
198.51.100.7 - bob [01/Jan/2025:10:01:12 +0000] "GET /dashboard HTTP/1.1" 301 0 "-" "Mozilla/5.0 (Macintosh)"
10.0.0.5 - - [01/Jan/2025:10:01:45 +0000] "GET /api/users HTTP/1.1" 401 89 "-" "PostmanRuntime/7.29"
172.16.0.22 - charlie [01/Jan/2025:10:02:30 +0000] "DELETE /api/resource/42 HTTP/1.1" 403 112 "-" "axios/1.3.0"
192.168.1.10 - alice [01/Jan/2025:10:03:00 +0000] "GET /static/app.js HTTP/1.1" 200 51200 "https://example.com/index.html" "Mozilla/5.0"
203.0.113.99 - - [01/Jan/2025:10:04:10 +0000] "GET /nonexistent HTTP/1.1" 404 162 "-" "Mozilla/5.0"
10.0.0.1 - admin [01/Jan/2025:10:05:00 +0000] "POST /api/data HTTP/1.1" 500 300 "-" "curl/7.68.0"
198.51.100.7 - bob [01/Jan/2025:10:06:22 +0000] "GET /health HTTP/1.1" 200 18 "-" "kube-probe/1.27"
172.16.0.99 - - [01/Jan/2025:10:07:55 +0000] "PUT /api/settings HTTP/1.1" 200 512 "https://example.com" "Mozilla/5.0 (Linux)"
192.168.1.55 - dave [01/Jan/2025:10:08:01 +0000] "GET /api/stream HTTP/1.1" 200 204800 "-" "VLC/3.0.18"
203.0.113.45 - - [01/Jan/2025:10:09:30 +0000] "GET /favicon.ico HTTP/1.1" 304 0 "-" "Mozilla/5.0"
10.0.0.5 - - [01/Jan/2025:10:10:00 +0000] "POST /api/login HTTP/1.1" 429 45 "-" "python-requests/2.28"
EOF

# ---------------------------------------------------------------------------
# 2. app.log  — JSON lines (structured application log)
# ---------------------------------------------------------------------------
cat > "$DATA_DIR/app.log" << 'EOF'
{"timestamp":"2025-01-01T10:00:00Z","level":"info","service":"auth-service","msg":"Server started","port":8080}
{"timestamp":"2025-01-01T10:00:05Z","level":"info","service":"auth-service","msg":"User login successful","user_id":"u_001","ip":"192.168.1.10"}
{"timestamp":"2025-01-01T10:00:12Z","level":"warn","service":"auth-service","msg":"Failed login attempt","user_id":"u_002","ip":"203.0.113.45","attempts":3}
{"timestamp":"2025-01-01T10:01:00Z","level":"info","service":"api-gateway","msg":"Request received","method":"GET","path":"/api/users","latency_ms":12}
{"timestamp":"2025-01-01T10:01:30Z","level":"error","service":"db-service","msg":"Connection timeout","host":"postgres:5432","retry":1}
{"timestamp":"2025-01-01T10:01:35Z","level":"error","service":"db-service","msg":"Connection timeout","host":"postgres:5432","retry":2}
{"timestamp":"2025-01-01T10:01:40Z","level":"info","service":"db-service","msg":"Connection restored","host":"postgres:5432"}
{"timestamp":"2025-01-01T10:02:00Z","level":"info","service":"api-gateway","msg":"Request received","method":"POST","path":"/api/data","latency_ms":45}
{"timestamp":"2025-01-01T10:02:15Z","level":"warn","service":"cache-service","msg":"Cache miss rate high","rate":0.87,"threshold":0.5}
{"timestamp":"2025-01-01T10:03:00Z","level":"info","service":"worker","msg":"Job completed","job_id":"j_9921","duration_ms":1200}
{"timestamp":"2025-01-01T10:03:30Z","level":"debug","service":"worker","msg":"Processing queue","queue_depth":14}
{"timestamp":"2025-01-01T10:04:00Z","level":"error","service":"payment-service","msg":"Payment gateway unreachable","gateway":"stripe","status_code":503}
{"timestamp":"2025-01-01T10:04:05Z","level":"critical","service":"payment-service","msg":"Payment processing halted","reason":"gateway_down"}
{"timestamp":"2025-01-01T10:05:00Z","level":"info","service":"payment-service","msg":"Payment gateway recovered","gateway":"stripe"}
{"timestamp":"2025-01-01T10:06:00Z","level":"info","service":"auth-service","msg":"Token refreshed","user_id":"u_001"}
{"timestamp":"2025-01-01T10:07:10Z","level":"warn","service":"api-gateway","msg":"Rate limit approaching","user_id":"u_005","requests":95,"limit":100}
{"timestamp":"2025-01-01T10:08:00Z","level":"info","service":"worker","msg":"Job queued","job_id":"j_9922","priority":"high"}
{"timestamp":"2025-01-01T10:09:00Z","level":"error","service":"storage-service","msg":"Disk usage critical","used_pct":92,"mount":"/var/data"}
{"timestamp":"2025-01-01T10:10:00Z","level":"info","service":"api-gateway","msg":"Health check passed","uptime_s":600}
EOF

# ---------------------------------------------------------------------------
# 3. syslog.log  — Classic syslog format
# ---------------------------------------------------------------------------
cat > "$DATA_DIR/syslog.log" << 'EOF'
Jan  1 10:00:01 webserver01 sshd[1234]: Accepted publickey for deploy from 192.168.1.5 port 54321 ssh2
Jan  1 10:00:45 webserver01 sudo[5678]: alice : TTY=pts/0 ; PWD=/var/www ; USER=root ; COMMAND=/bin/systemctl restart nginx
Jan  1 10:01:00 webserver01 nginx[910]: Starting nginx: nginx.
Jan  1 10:01:30 webserver01 kernel: OUT OF MEMORY: Kill process 3321 (java) score 870 or sacrifice child
Jan  1 10:02:00 webserver01 sshd[2345]: Failed password for root from 203.0.113.99 port 22 ssh2
Jan  1 10:02:01 webserver01 sshd[2345]: Failed password for root from 203.0.113.99 port 22 ssh2
Jan  1 10:02:02 webserver01 sshd[2345]: Failed password for root from 203.0.113.99 port 22 ssh2
Jan  1 10:02:03 webserver01 sshd[2346]: Disconnecting invalid user root 203.0.113.99 port 22
Jan  1 10:03:00 webserver01 cron[456]: (root) CMD (/usr/bin/certbot renew --quiet)
Jan  1 10:04:10 webserver01 dockerd[789]: time="2025-01-01T10:04:10" level=warning msg="container failed to exit within 10 seconds"
Jan  1 10:05:00 webserver01 systemd[1]: Started Daily apt upgrade and clean activities.
Jan  1 10:06:15 webserver01 kernel: eth0: renamed from veth3a2b1c
Jan  1 10:07:30 webserver01 postfix/smtp[6543]: connect to mail.example.com[93.184.216.34]:25: Connection timed out
Jan  1 10:08:00 webserver01 sshd[7890]: Accepted password for bob from 10.0.0.15 port 43210 ssh2
Jan  1 10:09:45 webserver01 ufw[999]: [UFW BLOCK] IN=eth0 OUT= SRC=45.33.32.156 DST=203.0.113.1 PROTO=TCP DPT=3306
Jan  1 10:10:00 webserver01 sshd[1234]: Received disconnect from 192.168.1.5 port 54321:11: disconnected by user
EOF

# ---------------------------------------------------------------------------
# 4. plain.log  — Plain text app log (mixed levels)
# ---------------------------------------------------------------------------
cat > "$DATA_DIR/plain.log" << 'EOF'
2025-01-01 10:00:00 INFO  Application starting up...
2025-01-01 10:00:01 INFO  Loading configuration from /etc/app/config.yaml
2025-01-01 10:00:02 INFO  Database connection pool initialized (size=10)
2025-01-01 10:00:03 INFO  Message queue connected: amqp://rabbitmq:5672
2025-01-01 10:00:05 INFO  HTTP server listening on :8080
2025-01-01 10:01:00 DEBUG Incoming request: GET /api/status
2025-01-01 10:01:01 DEBUG Cache lookup: HIT for key=status_v2
2025-01-01 10:02:00 WARN  Memory usage above 75%: 3.1GB / 4GB
2025-01-01 10:02:30 INFO  Background job scheduler started, next run in 60s
2025-01-01 10:03:00 DEBUG Incoming request: POST /api/ingest
2025-01-01 10:03:01 INFO  Ingested 1500 records in 230ms
2025-01-01 10:04:00 ERROR Failed to send email notification: SMTP connection refused (host=smtp.example.com:587)
2025-01-01 10:04:01 WARN  Retrying email send in 30s (attempt 1/3)
2025-01-01 10:04:31 WARN  Retrying email send in 30s (attempt 2/3)
2025-01-01 10:05:01 ERROR Email notification failed after 3 attempts. Dropping message.
2025-01-01 10:06:00 INFO  Scheduled cleanup: removed 412 expired sessions
2025-01-01 10:07:00 WARN  Slow query detected (450ms): SELECT * FROM events WHERE user_id=?
2025-01-01 10:08:00 DEBUG Incoming request: GET /metrics
2025-01-01 10:09:00 INFO  Health check: OK (uptime=540s, memory=3.1GB, cpu=12%)
2025-01-01 10:10:00 FATAL Unhandled exception in worker thread: NullPointerException at line 342
EOF

echo ""
echo "✅ Done! Files created:"
ls -lh "$DATA_DIR"
echo ""
echo "👉 Now restart Filebeat to pick them up:"
echo "   docker restart filebeat"
