variable "instance_type" {
  description = "Type of EC2 instance"
  default     = "t2.micro"
}

variable "stage" {
  description = "Deployment stage (dev, prod, etc.)"
  default     = "dev"
}
