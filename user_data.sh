#!/bin/bash
set -e

# Terraform injects this automatically
LOG_BUCKET="${log_bucket_name}"

sudo apt-get update -y
sudo apt-get install -y openjdk-17-jdk git maven awscli nginx

# ------- Clone & Build App -------
cd /home/ubuntu
if [ ! -d "/home/ubuntu/app" ]; then
  git clone https://github.com/Trainings-TechEazy/test-repo-for-devops.git app
fi
cd /home/ubuntu/app
mvn clean package -DskipTests
JAR_FILE=$(find target -name "*.jar" | head -n 1)

# ------- Run Spring Boot Backend (on 8080) -------
nohup java -jar "$JAR_FILE" --server.port=8080 > /home/ubuntu/app.log 2>&1 &

# ------- Custom Landing Page (Port 80) -------
sudo bash -c 'cat > /var/www/html/index.html <<EOF
<!doctype html>
<html>
<head>
  <meta charset="utf-8"/>
  <title>Kailash Chaudhary</title>
  <style>
    body {font-family: Arial, sans-serif; background:#f9f9f9; margin:40px;}
    .card {background:white; padding:30px; border-radius:12px;
           box-shadow:0 0 12px rgba(0,0,0,0.1);}
    h1 {color:#2b7de9;}
  </style>
</head>
<body>
  <div class="card">
    <h1>🚀 Kailash Chaudhary’s App</h1>
    <p>This is served through Nginx (80) → Spring Boot (8080)</p>
    <p>Visit <a href="/app">/app</a> to open the backend app.</p>
  </div>
</body>
</html>
EOF'

# ------- Nginx Reverse Proxy -------
sudo bash -c 'cat > /etc/nginx/sites-available/default <<NGINX
server {
  listen 80 default_server;
  listen [::]:80 default_server;
  server_name _;
  root /var/www/html;
  index index.html;

  location / {
    try_files \$uri \$uri/ =404;
  }

  location /app/ {
    proxy_pass http://127.0.0.1:8080/;
    proxy_set_header Host \$host;
  }
}
NGINX'

sudo systemctl restart nginx
sudo systemctl enable nginx

# ------- Create Cron Job for Log Upload (Guaranteed) -------
sudo tee /etc/cron.d/app-log-upload > /dev/null <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
AWS_DEFAULT_REGION=ap-south-1

* * * * * root [ -f /home/ubuntu/app.log ] && /usr/bin/aws s3 cp /home/ubuntu/app.log "s3://$${LOG_BUCKET}/\$(hostname)-app.log" --quiet
EOF

sudo chmod 644 /etc/cron.d/app-log-upload
sudo systemctl restart cron
echo "✅ Cron job created for log uploads to $${LOG_BUCKET}"