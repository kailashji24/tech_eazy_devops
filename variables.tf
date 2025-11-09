variable "region" {
  description = "AWS region"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "AWS key pair name"
  type        = string
}

variable "stage" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "owner_name" {
  description = "Your name for personalization"
  type        = string
  default     = "Kailash Chaudhary"
}
