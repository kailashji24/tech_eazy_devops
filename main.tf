###########################################
# Terraform Provider & Setup
###########################################
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.4.0"
}

provider "aws" {
  region = var.region
}

###########################################
# Random ID for unique resource names
###########################################
resource "random_id" "suffix" {
  byte_length = 3
}

###########################################
# S3 Bucket for Logs
###########################################
resource "aws_s3_bucket" "log_bucket" {
  bucket = "dev-app-logs-${random_id.suffix.hex}"
  force_destroy = true
}

###########################################
# IAM Role, Policy, and Instance Profile
###########################################
resource "aws_iam_role" "ec2_role" {
  name = "ec2-s3-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_policy" {
  name   = "ec2-s3-policy-${random_id.suffix.hex}"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3Access"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.log_bucket.bucket}",
          "arn:aws:s3:::${aws_s3_bucket.log_bucket.bucket}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-s3-profile-${random_id.suffix.hex}"
  role = aws_iam_role.ec2_role.name
}

###########################################
# Security Groups
###########################################
# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg-${random_id.suffix.hex}"
  description = "Allow HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id

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
}

# EC2 Security Group
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg-${random_id.suffix.hex}"
  description = "Allow inbound from ALB and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

###########################################
# EC2 Instances
###########################################
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_instance" "app" {
  count                       = 3
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  subnet_id                   = element(data.aws_subnets.default.ids, count.index)
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

user_data = templatefile("${path.module}/user_data.sh", {
  log_bucket_name = aws_s3_bucket.log_bucket.bucket
})

  tags = {
    Name  = "app-${count.index + 1}"
    Stage = var.stage
  }
}

###########################################
# Application Load Balancer (ALB)
###########################################
resource "aws_lb" "app_alb" {
  name               = "dev-app-alb-${random_id.suffix.hex}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = data.aws_subnets.default.ids
}

resource "aws_lb_target_group" "tg" {
  name     = "dev-app-tg-${random_id.suffix.hex}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

resource "aws_lb_target_group_attachment" "app_attachment" {
  count             = 3
  target_group_arn  = aws_lb_target_group.tg.arn
  target_id         = aws_instance.app[count.index].id
  port              = 80
}

###########################################
# Outputs
###########################################
output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "log_bucket_name" {
  value = aws_s3_bucket.log_bucket.bucket
}
