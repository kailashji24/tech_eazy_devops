# 🚀 Assignment 2 – Automated Infrastructure Deployment Using Terraform

This project is a **fully automated AWS infrastructure** built with Terraform.  
It extends **Assignment 1** by introducing **scalability, automation, centralized logging**, and **real-world production practices**.

Developed over multiple days, this setup demonstrates how Infrastructure as Code (IaC) can be used to build, configure, and scale applications seamlessly on AWS.

---

## 🧩 Overview

This deployment performs **complete infrastructure automation**:
- Provisions **3 EC2 instances** automatically using Terraform `count`
- Installs **Java, Maven, AWS CLI, and Nginx** via the `user_data.sh` script
- Clones and builds a **Spring Boot application** from GitHub
- Runs the backend on **port 8080**
- Configures **Nginx** as a reverse proxy (port 80) and hosts a **custom landing page**
- Creates an **Application Load Balancer (ALB)** for traffic distribution
- Sets up **IAM roles and policies** for S3 log uploads
- Adds a **cron job** to each EC2 instance to upload logs to **S3** every minute

Everything is handled by **one command**:  
```bash
terraform apply -var-file="dev.tfvars" -auto-approve
```

No manual steps or configuration needed after deployment.

---

## ⚙️ Architecture

```text
                 +-----------------------------+
                 |      AWS Load Balancer      |
                 +--------------+--------------+
                                |
            +-------------------+-------------------+
            |                   |                   |
      EC2 Instance 1      EC2 Instance 2      EC2 Instance 3
            |                   |                   |
     +------+-----+       +------+-----+       +------+-----+
     |  Spring Boot |     |  Spring Boot |     |  Spring Boot |
     |  (port 8080) |     |  (port 8080) |     |  (port 8080) |
     +------+-----+       +------+-----+       +------+-----+
            |                   |                   |
         Nginx (80)         Nginx (80)         Nginx (80)
                                |
                                |
                 +-----------------------------+
                 |         S3 Log Bucket       |
                 +-----------------------------+
```

---

## 🧱 Components

| Resource | Purpose |
|-----------|----------|
| **ALB (Application Load Balancer)** | Distributes incoming traffic across EC2 instances |
| **EC2 Instances (3)** | Host Spring Boot app and handle log uploads |
| **S3 Bucket** | Stores application logs uploaded from EC2 |
| **IAM Role & Policy** | Grants EC2 permission to write logs to S3 |
| **Nginx** | Hosts landing page and proxies requests to backend |
| **Cron Job** | Automates periodic log uploads to S3 |
| **Terraform** | Manages complete infrastructure setup and teardown |

---

## 🧩 How It Works

1. **Infrastructure Creation**
   ```bash
   terraform init -upgrade
   terraform validate
   terraform plan -var-file="dev.tfvars"
   terraform apply -var-file="dev.tfvars" -auto-approve
   ```

2. **Bootstrapping**
   - The `user_data.sh` script runs automatically on instance creation.
   - It installs dependencies and clones the app from GitHub.
   - Builds the `.jar` using Maven.
   - Starts the Spring Boot app on port 8080.
   - Configures Nginx reverse proxy and custom HTML landing page.
   - Creates a cron job to upload logs to S3 every minute.

3. **Access**
   - **Landing Page:** `http://<alb_dns_name>`
   - **Backend App:** `http://<alb_dns_name>/app`
   - **Logs:** Available in S3 bucket (`log_bucket_name`)

---

## 🧾 Example Terraform Outputs

```
alb_dns_name    = "dev-app-alb-53ec44-852222316.ap-south-1.elb.amazonaws.com"
log_bucket_name = "dev-app-logs-53ec44"
```

**Access the application:**
👉 [http://dev-app-alb-53ec44-852222316.ap-south-1.elb.amazonaws.com](http://dev-app-alb-53ec44-852222316.ap-south-1.elb.amazonaws.com)

**Check logs in S3:**
👉 [https://s3.console.aws.amazon.com/s3/buckets/dev-app-logs-53ec44](https://s3.console.aws.amazon.com/s3/buckets/dev-app-logs-53ec44)

---

## 🔧 Variables (`dev.tfvars`)

```hcl
region         = "ap-south-1"
stage          = "dev"
instance_type  = "t2.micro"
key_name       = "devops-key"
custom_name    = "Kailash Chaudhary"
app_repo_url   = "https://github.com/Trainings-TechEazy/test-repo-for-devops.git"
```

---

## 🧰 Files Included

| File | Description |
|------|--------------|
| `main.tf` | Core Terraform configuration |
| `variables.tf` | Variable definitions |
| `dev.tfvars` | Environment variable values |
| `iam-policy.json` | IAM permissions for S3 access |
| `user_data.sh` | Startup automation script |
| `terraform.tfstate` | Terraform state file |
| `terraform.tfstate.backup` | Backup state |
| `.terraform.lock.hcl` | Provider lock file |
| `README.md` | Documentation (this file) |

---

## 📊 Key Highlights

| Feature | Description |
|----------|--------------|
| **Full Automation** | One-step provisioning using Terraform |
| **Scalability** | 3-instance architecture with ALB |
| **Centralized Logging** | S3-based log uploads from EC2 |
| **IAM Security** | Fine-grained S3 write permissions |
| **Zero Manual Steps** | Fully automated from infra to app |
| **Custom Web UI** | Personalized HTML landing page |

---

## 🧠 Key Learnings

- **Infrastructure as Code (IaC)** using Terraform  
- Multi-tier AWS architecture with **ALB + EC2 + S3**  
- Secure access control via **IAM roles & policies**  
- Automated **application provisioning and deployment**  
- **Log management** with cron and S3 integration  
- Real-world **scaling and maintainability practices**

---

## 🧹 Destroy Infrastructure

When finished, clean up all resources:
```bash
terraform destroy -var-file="dev.tfvars" -auto-approve
```
✅ This prevents extra AWS billing and keeps the environment tidy.

---

## 👨‍💻 Author

**Kailash Chaudhary**  
B.E. – Computer Science & Engineering  
Pravara Rural Engineering College, Loni  
*(Affiliated to Savitribai Phule Pune University)*  
📍 Pune City, India  
🔗 [LinkedIn Profile](https://www.linkedin.com/in/kailash-chaudhary24)

---

## 🏁 Summary

> This project demonstrates **end-to-end AWS automation** using Terraform.  
> From provisioning to configuration to logging, every step runs autonomously.  
> It showcases how DevOps principles can achieve repeatable, scalable, and reliable cloud environments with zero manual intervention.
