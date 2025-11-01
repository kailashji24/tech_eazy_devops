# DevOps Assignment 1 – Terraform

## 📘 Description
This project deploys an EC2 instance using Terraform on AWS.

## ⚙️ Prerequisites
- Terraform v1.6 or above  
- AWS CLI configured with valid credentials  
- An active AWS account

## 🚀 How to Run
1. Clone this repository  
   ```bash
   git clone https://github.com/kailashji24/tech_eazy_devops.git
   cd tech_eazy_devops
   ```
2. Initialize Terraform  
   ```bash
   terraform init
   ```
3. Plan your deployment  
   ```bash
   terraform plan -var-file="dev.tfvars"
   ```
4. Apply the changes  
   ```bash
   terraform apply -var-file="dev.tfvars"
   ```

## 🧹 Cleanup
To destroy all resources created:
```bash
terraform destroy -var-file="dev.tfvars"
```

## ✍️ Notes
This version adds a README file and comments within Terraform files for clarity.
