provider "aws" {
  region = var.region
}

# Fetch default VPC and subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group
resource "aws_security_group" "app_sg" {
  name        = "${var.stage}-app-sg"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.stage}-app-sg"
    Stage = var.stage
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                         = "ami-08e5424edfe926b43" # Ubuntu 20.04 LTS – ap-south-1
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  subnet_id                   = data.aws_subnets.default.ids[0]
  associate_public_ip_address = true

  user_data = <<-EOF
    #!/bin/bash
    set -e

    OWNER_NAME="${var.owner_name}"
    STAGE="${var.stage}"

    apt-get update -y
    apt-get install -y git openjdk-17-jdk maven net-tools lsof

    cd /root

    PID=$(lsof -t -i:80 || true)
    if [ -n "$PID" ]; then
      kill -9 $PID || true
    fi

    if [ ! -d test-repo-for-devops ]; then
      git clone https://github.com/Trainings-TechEazy/test-repo-for-devops.git
    fi
    cd test-repo-for-devops

    mkdir -p src/main/resources/static

    cat <<HTMLPAGE > src/main/resources/static/index.html
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="utf-8"/>
      <title>EC2 Deployment – $${OWNER_NAME}</title>
      <style>
        body {font-family: Arial, sans-serif; margin: 50px; line-height:1.6;}
        h1 {color:#0078D7;}
        .card {border:1px solid #ddd; border-radius:10px; padding:30px; max-width:900px; margin:auto; box-shadow:0 2px 8px rgba(0,0,0,0.1);}
        code {background:#f5f5f5; padding:2px 6px; border-radius:5px;}
      </style>
    </head>
    <body>
      <div class="card">
        <h1>✅ Terraform EC2 Deployment – $${OWNER_NAME}</h1>
        <h3>Stage: $${STAGE}</h3>
        <p>This page is served by a Spring Boot application running on an Ubuntu 20.04 EC2 instance provisioned via Terraform.</p>
        <h2>Deployment Steps</h2>
        <ol>
          <li>Terraform created the EC2 instance & security group.</li>
          <li>User data installed Git, Java 17, Maven, and dependencies.</li>
          <li>The repository <code>Trainings-TechEazy/test-repo-for-devops</code> was cloned and built.</li>
          <li>The application was started automatically on <code>HTTP :80</code>.</li>
          <li>The instance will automatically shut down after 30 minutes.</li>
        </ol>
        <h2>Verification</h2>
        <ul>
          <li>Visit: <code>http://&lt;public-ip&gt;</code> (not HTTPS)</li>
          <li>Check logs: <code>sudo tail -n 30 /root/app.log</code></li>
        </ul>
      </div>
    </body>
    </html>
    HTMLPAGE

    mvn clean package -DskipTests
    JAR_FILE=$(find target -name "*.jar" | head -n 1)
    setcap 'cap_net_bind_service=+ep' "$(readlink -f "$(which java)")"
    nohup java -jar "$JAR_FILE" --server.port=80 > /root/app.log 2>&1 &

    sleep 1800
    shutdown -h now
  EOF

  tags = {
    Name  = "${var.stage}-app-server"
    Stage = var.stage
  }
}

# Outputs
output "instance_public_ip" {
  description = "Public IP of the deployed EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "instance_public_dns" {
  description = "Public DNS of the deployed EC2 instance"
  value       = aws_instance.app_server.public_dns
}
