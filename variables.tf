terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "region" {
  type    = string
  default = "ap-south-1"
}

variable "stage" {
  type    = string
  default = "dev"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "Existing EC2 key pair name in the target region"
}

variable "custom_name" {
  type    = string
  default = "kailash-chaudhary"
}

variable "app_repo_url" {
  type    = string
  default = "https://github.com/Trainings-TechEazy/test-repo-for-devops.git"
}

variable "app_bucket" {
  type        = string
  description = "S3 bucket name that contains the application jar (manually created)"
}

variable "instance_count" {
  type    = number
  default = 3
}
