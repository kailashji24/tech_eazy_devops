#!/bin/bash
# Update the system
sudo yum update -y

# Install required packages
sudo yum install -y git java-17-amazon-corretto maven

# Move to ec2-user's home directory
cd /home/ec2-user

# Clone your GitHub repo
git clone https://github.com/KailashDhakad24/test-repo-for-devops.git

# Go into your repo
cd test-repo-for-devops

# Build your Java project
mvn clean package

# Find and run the JAR file
JAR_FILE=$(find /home/ec2-user/test-repo-for-devops/target -type f -name "*.jar" | head -n 1)

# Debug log: record which jar we found
echo "Running JAR: $JAR_FILE" > /home/ec2-user/app.log

# Run your app on port 8080 and redirect 80 -> 8080
sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080

# Run the app
nohup java -jar "$JAR_FILE" > /home/ec2-user/app.log 2>&1 &
