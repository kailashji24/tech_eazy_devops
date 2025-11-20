# 📘 Assignment 3 – Auto Scaling, ALB, Monitoring & WAF (Terraform)

This project automates a complete scalable web application setup on AWS using Terraform, including Auto Scaling, Load Balancing, Monitoring, WAF protection, and automated deployment.

## 🚀 Architecture Overview
Components:
- VPC & Subnets
- Security Groups
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- CloudWatch Dashboard & Logs
- WAF (DDoS protection)
- EC2 Launch Template with User Data
- S3 for log storage

## 📂 Repository Structure
- main.tf  
- alb_and_asg.tf  
- network_and_security.tf  
- monitoring.tf  
- user-data.sh  
- load-test.sh  
- outputs.tf  
- .gitignore  

## ⚙️ Features Implemented
- Auto Scaling Group with CPU-based scaling  
- ALB routing to port 8080  
- WAF Web ACL with rate limiting  
- CloudWatch Dashboard (CPU, ALB, WAF, ASG metrics)  
- S3 log upload  
- Fully automated EC2 bootstrap  

## 🧪 Load Testing
```
chmod +x load-test.sh
./load-test.sh <ALB-DNS>
```

## 🧹 Cleanup
```
terraform destroy -auto-approve
```

## ✅ Status
All Assignment 3 requirements completed and verified.
