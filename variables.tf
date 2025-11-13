variable "region"        { type = string }
variable "stage"         { type = string }
variable "instance_type" { type = string }
variable "key_name"      { type = string }
variable "custom_name"   { type = string }
variable "app_repo_url"  { type = string }

variable "ami_id" {
  type    = string
  default = "ami-0dee22c13ea7a9a67" # Ubuntu 22.04 in ap-south-1
}
