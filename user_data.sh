#!/bin/bash
# =====================================================
# Final – DevOps Assignment 1 (Ubuntu 20.04, stable)
# =====================================================

sudo apt-get update -y
sudo apt-get install -y git openjdk-17-jdk maven net-tools

cd /root || cd /home/ubuntu

# Stop any previous process using port 80
PID=$(lsof -t -i:80)
if [ -n "$PID" ]; then
  kill -9 $PID
fi

# Clone and build
git clone https://github.com/Trainings-TechEazy/test-repo-for-devops.git || true
cd test-repo-for-devops
mvn clean package -DskipTests

# Run app on port 80
JAR_FILE=$(find target -name "*.jar" | head -n 1)
sudo setcap 'cap_net_bind_service=+ep' $(readlink -f $(which java))
nohup java -jar "$JAR_FILE" --server.port=80 > /root/app.log 2>&1 &

# Auto-shutdown after 30 minutes
sleep 1800
sudo shutdown -h now
