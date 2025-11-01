# Added by Kailash Chaudhary for Assignment 1 - PR demonstration
provider "aws" {
  region = "ap-south-1" # Mumbai region
}

# Security Group
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "App Port 8080"
    from_port   = 8080
    to_port     = 8080
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
    Name = "allow_ssh_http"
  }
}

# EC2 Instance (Ubuntu)
resource "aws_instance" "my_ec2" {
  ami                    = "ami-0522ab6e1ddcc7055" # Ubuntu 22.04 LTS (ap-south-1)
  instance_type          = "t2.micro"
  key_name               = "devops-key" # Use the key you created
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install -y openjdk-17-jdk maven git

              cd /home/ubuntu
              git clone https://github.com/Trainings-TechEazy/test-repo-for-devops.git
              cd test-repo-for-devops

              mvn clean package

              nohup java -jar target/techeazy-devops-0.0.1-SNAPSHOT.jar > /home/ubuntu/app.log 2>&1 &
              EOF

  tags = {
    Name = "DevOps-Assignment-Instance"
  }
}

# Output
output "public_ip" {
  value = aws_instance.my_ec2.public_ip
}
