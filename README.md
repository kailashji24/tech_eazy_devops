# 🚀 Assignment 2 – Automated Infrastructure Deployment Using Terraform

This project demonstrates a fully automated AWS infrastructure using Terraform.  
It provisions a scalable, production-like environment consisting of:

- **Application Load Balancer (ALB)**
- **EC2 instances (auto-configured)**
- **Custom NGINX landing page**
- **Spring Boot backend (JAR pulled from S3)**
- **Centralized S3 log storage**
- **IAM roles & cron-based automation**

Everything is deployed using a single command:


terraform apply -var-file="dev.tfvars" -auto-approve


## 🧩 Overview

This deployment includes:

- 🚀 3 EC2 instances created using Terraform `count`
- 📦 Spring Boot JAR downloaded from an **S3 app bucket**
- 📡 ALB distributing traffic across all EC2 instances
- 📝 Custom HTML landing page via NGINX
- 🔁 Reverse proxy `/app/` → backend (8080)
- 📤 Cron job uploading logs to S3 every minute
- 🔐 IAM role granting secure S3 write access
- ⚙️ Full automation via `user_data.sh`



## ⚙️ Architecture


                 +-----------------------------+
                 |      AWS Load Balancer      |
                 +--------------+--------------+
                                |
            +-------------------+-------------------+
            |                   |                   |
      EC2 Instance 1      EC2 Instance 2      EC2 Instance 3
            |                   |                   |
     +------+-----+       +------+-----+       +------+-----+
     | Spring Boot |      | Spring Boot |      | Spring Boot |
     |  (8080)     |      |  (8080)     |      |  (8080)     |
     +------+-----+       +------+-----+       +------+-----+
            |                   |                   |
         NGINX (80)         NGINX (80)         NGINX (80)
                                |
                                |
                 +-----------------------------+
                 |         S3 Log Bucket       |
                 +-----------------------------+




## 🧱 Components

| Component | Purpose |
|----------|---------|
| **ALB** | Load balances incoming traffic |
| **3× EC2 Instances** | Host backend + NGINX |
| **S3 Log Bucket** | Stores uploaded logs |
| **S3 App Bucket** | Contains backend JAR |
| **IAM Role & Policy** | Enables EC2 → S3 log upload |
| **NGINX** | Frontend + reverse proxy |
| **Cron Job** | Uploads logs every minute |
| **Terraform** | IaC automation |

---

## 🧩 How It Works

### 1️⃣ Infrastructure Provisioning


terraform init -upgrade
terraform validate
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars" -auto-approve


### 2️⃣ EC2 Bootstrapping (`user_data.sh`)

Each EC2 instance performs:

- Installs **Java 17**, **AWS CLI**, **NGINX**
- Downloads backend JAR from:


s3://<APP_BUCKET>/builds/app.jar

- Starts Spring Boot on **8080**
- Configures NGINX:
  - `/` → Custom HTML page  
  - `/app/` → Reverse proxy to backend  

- Creates cron job:


* * * * * aws s3 cp /home/ubuntu/app.log s3://<LOG_BUCKET>/logs/$(hostname).log



### 3️⃣ Access

**Frontend:**

http://<alb_dns_name>


**Backend API:**

http://<alb_dns_name>/app/hello


**Logs in S3:**

s3://<log_bucket_name>/logs/



## 🧾 Example Outputs

alb_dns_name    = "dev-app-alb-7607d7-35193649.ap-south-1.elb.amazonaws.com"
log_bucket_name = "dev-app-logs-7607d7"



## 🔧 Variables (`dev.tfvars`)

region         = "ap-south-1"
stage          = "dev"
instance_type  = "t3.micro"
key_name       = "devops-key"
custom_name    = "kailash"
app_bucket     = "assignment2-app-bucket"
instance_count = 3




## 📂 Files Included

| File | Description |
|------|-------------|
| `main.tf` | Core infrastructure |
| `variables.tf` | Input variables |
| `dev.tfvars` | Environment configuration |
| `user_data.sh` | EC2 boot automation |
| `iam-policy.json` | S3 access policy |
| `.gitignore` | Prevents committing state files |
| `README.md` | Documentation |


## 📊 Key Highlights

- ✔ JAR downloaded from S3, not GitHub  
- ✔ Complete automation end-to-end  
- ✔ Scalable EC2 cluster behind ALB  
- ✔ Centralized logging in S3  
- ✔ Custom web UI  
- ✔ Clean IaC architecture  



## 🧹 Destroy Infrastructure

terraform destroy -var-file="dev.tfvars" -auto-approve


## 👨‍💻 Author

**Kailash Chaudhary**  
B.E. – Computer Science & Engineering  
Pravara Rural Engineering College, Loni  
(Affiliated to Savitribai Phule Pune University)  
📍 Pune City, India  
🔗 LinkedIn: https://www.linkedin.com/in/kailash-chaudhary24



## 🏁 Summary

This project demonstrates a complete AWS automation pipeline using Terraform—covering compute, networking, reverse proxying, logging, and automation, reflecting real-world DevOps workflows.
