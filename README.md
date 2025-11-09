# 🚀 DevOps Assignment 1 — Automated EC2 Deployment with Terraform

## 👨‍💻 Author  
**Kailash Chaudhary**

---

## 📘 Overview

This project automates the provisioning and deployment of a Spring Boot web application on **AWS EC2** using **Terraform**.  
The infrastructure and application setup are performed automatically using a **user_data** script on an **Ubuntu 20.04** instance.

After deployment, the application runs on **HTTP port 80** and serves a custom HTML page that displays my name and detailed deployment steps.

---

## 🧩 Key Features

- **Fully Automated Infrastructure Setup**
  - EC2 instance creation (Ubuntu 20.04)
  - Security Group allowing ports **22 (SSH)** and **80 (HTTP)**
  - Automatic package installation: Git, Java 17, Maven
- **Application Deployment**
  - Clones the `Trainings-TechEazy/test-repo-for-devops` repository
  - Builds the project using Maven
  - Runs the Spring Boot JAR file on port 80
- **Custom Web Page**
  - Displays my name and deployment steps dynamically
  - Served automatically by Spring Boot under `/`
- **Auto-Shutdown**
  - Instance stops after 30 minutes to save resources

---

## ⚙️ Terraform Components

| File | Description |
|------|--------------|
| **main.tf** | Terraform configuration (resources, EC2, user_data) |
| **variables.tf** | Variable declarations |
| **dev.tfvars** | Environment-specific variable values |
| **.gitignore** | Ignored files (e.g., state files, local configs) |

---

## 🧠 Variables (from `dev.tfvars`)

```hcl
region        = "ap-south-1"
instance_type = "t2.micro"
key_name      = "devops-key"
stage         = "dev"
owner_name    = "Kailash Chaudhary"
