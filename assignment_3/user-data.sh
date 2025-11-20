#!/bin/bash

APP_BUCKET="${app_bucket_name}"
JAR_KEY="${jar_key}"
LOG_BUCKET="${logs_bucket}"

JAR_NAME=$(basename "$JAR_KEY")
LOG_PATH="/var/log/myapp"
JAR_PATH="/home/ec2-user/$JAR_NAME"

yum update -y
yum install -y java-17-amazon-corretto-headless awscli jq

mkdir -p "$LOG_PATH"

sleep 5

aws s3 cp "s3://$APP_BUCKET/$JAR_KEY" "$JAR_PATH"
chmod +x "$JAR_PATH"

nohup java -jar "$JAR_PATH" --server.port=8080 > "$LOG_PATH/myapp.log" 2>&1 &

# -------------------------------------------------------
# Setup Cron job to periodically upload logs to S3
# -------------------------------------------------------
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
CRON_JOB_FILE="/home/ec2-user/upload_logs.sh"

cat << EOF > $CRON_JOB_FILE
#!/bin/bash
# Upload logs with a unique timestamp
aws s3 cp "$LOG_PATH/myapp.log" "s3://$LOG_BUCKET/ec2-logs/$INSTANCE_ID/\$(date +\%Y-\%m-\%d-\%H\%M).log"
EOF

chmod +x $CRON_JOB_FILE

# Run every 5 minutes
(crontab -l 2>/dev/null; echo "*/5 * * * * $CRON_JOB_FILE") | crontab -