########################################
# PROVIDER
########################################

provider "aws" {
  region = var.region
}

########################################
# DATA SOURCES
########################################

# Default VPC in the region
data "aws_vpc" "default" {
  default = true
}

# All subnets in the default VPC
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

########################################
# S3 LOGS BUCKET (created by Terraform)
########################################

resource "aws_s3_bucket" "logs" {
  bucket = "${var.stage}-app-logs-${substr(md5(var.custom_name), 0, 6)}"
  
  # FIX: Allows Terraform to delete the bucket even if logs are present (BucketNotEmpty fix)
  force_destroy = true 

  tags = {
    Name  = "logs-bucket"
    Stage = var.stage
  }
}

########################################
# IAM ROLE + POLICY FOR EC2
########################################

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name               = "${var.stage}-ec2-role-${substr(md5(var.custom_name), 0, 6)}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_policy" "s3_policy" {
  name   = "${var.stage}-ec2-s3-policy-${substr(md5(var.custom_name), 0, 6)}"
  policy = file("${path.module}/iam-policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.stage}-ec2-profile-${substr(md5(var.custom_name), 0, 6)}"
  role = aws_iam_role.ec2_role.name
}

########################################
# SECURITY GROUP
########################################

resource "aws_security_group" "app_sg" {
  name        = "${var.stage}-app-sg"
  description = "Allow HTTP and SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

########################################
# EC2 INSTANCES
########################################

resource "aws_instance" "app" {
  count = var.instance_count

  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.instance_type
  key_name                    = var.key_name
  subnet_id                   = element(data.aws_subnets.default.ids, count.index)
  vpc_security_group_ids      = [aws_security_group.app_sg.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = true

  # Two-Bucket Logic: Pass App Bucket (static) and Log Bucket (dynamic)
  user_data = templatefile("${path.module}/user_data.sh", {
    APP_BUCKET  = var.app_bucket
    LOG_BUCKET  = aws_s3_bucket.logs.bucket
  })

  tags = {
    Name  = "${var.stage}-app-${count.index + 1}"
    Stage = var.stage
  }
}

########################################
# APPLICATION LOAD BALANCER
########################################

resource "aws_lb" "app_alb" {
  name               = "${var.stage}-app-alb-${substr(md5(var.custom_name), 0, 6)}"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  
  # FIX: Add Security Group to the ALB 
  security_groups    = [aws_security_group.app_sg.id]

  tags = {
    Name = "app-alb"
  }
}

resource "aws_lb_target_group" "app_tg" {
  name     = "${var.stage}-app-tg-${substr(md5(var.custom_name), 0, 6)}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

health_check {
    # FINAL FIX: Change Health Check Path to /app/hello 
    path                = "/app/hello"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}

# Register EC2 instances with target group
resource "aws_lb_target_group_attachment" "tg_attach" {
  count            = var.instance_count
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.app[count.index].id
  port             = 80
}

########################################
# OUTPUTS
########################################

output "alb_dns_name" {
  value       = aws_lb.app_alb.dns_name
  description = "ALB DNS name to access your application"
}

output "log_bucket_name" {
  value       = aws_s3_bucket.logs.bucket
  description = "S3 bucket where EC2 uploads logs"
}