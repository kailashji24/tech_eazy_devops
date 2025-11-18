#!/bin/bash
set -e

sudo apt-get update -y
sudo apt-get install -y openjdk-17-jdk awscli nginx

mkdir -p /home/ubuntu/app
chown ubuntu:ubuntu /home/ubuntu/app

# Download JAR from S3 (Uses APP_BUCKET for the permanent artifact)
aws s3 cp "s3://${APP_BUCKET}/builds/app.jar" /home/ubuntu/app/app.jar

# ----------------------------------------------------
# 🛠️ FIX FOR CUSTOM WEB PAGE
# ----------------------------------------------------

# 1. Create a directory for the custom page and set ownership
sudo mkdir -p /var/www/html/custom
sudo chown -R ubuntu:ubuntu /var/www/html

# 2. Create the Custom HTML Page (Your name/details)
sudo bash -c "cat > /var/www/html/custom/index.html <<'HTML_EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Kailash Chaudhary - DevOps Assignment</title>
    <style>body { font-family: Arial, sans-serif; background-color: #f4f4f4; text-align: center; padding-top: 50px; } h1 { color: #333; } p { color: #666; }</style>
</head>
<body>
    <h1>Welcome, this is the Web Server of Kailash Chaudhary!</h1>
    <p>Infrastructure deployed using Terraform and running on AWS EC2.</p>
    <hr>
    <p>Backend Status: <a href='/app/hello'>/app/hello</a></p>
    <p>Application Logs are being pushed to S3 bucket: ${LOG_BUCKET}</p>
</body>
</html>
HTML_EOF"

# 3. Configure NGINX to serve the custom page at / and proxy the app at /app/
sudo bash -c "cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 80;
    
    # Root location serves the static custom page
    location / {
        root /var/www/html/custom;
        index index.html;
    }

    # New location to proxy application traffic (e.g., /app/)
    location /app/ {
        # The trailing slash here is CRITICAL for correct proxying
        proxy_pass http://127.0.0.1:8080/; 
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF"

sudo systemctl restart nginx

# ----------------------------------------------------
# END FIX
# ----------------------------------------------------

# Run app 
sudo -u ubuntu bash -c "nohup java -jar /home/ubuntu/app/app.jar --server.port=8080 > /home/ubuntu/app.log 2>&1 &"

# Log upload every 1 min (Uses LOG_BUCKET for the temporary logs)
sudo bash -c "cat >/etc/cron.d/app-log-upload <<EOF
* * * * * root aws s3 cp /home/ubuntu/app.log s3://${LOG_BUCKET}/logs/\$(hostname)-app.log --region ap-south-1 --quiet
EOF"