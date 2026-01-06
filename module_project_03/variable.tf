variable "region" {
  description = "Region where you  want to launch the resources"
  default     = "us-east-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

# SSH allowed CIDR (for public security group / bastion)
variable "allowed_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0" # override in env files => restrict this!
}

variable "asg_min" {
  type    = number
  default = 2
}
variable "asg_max" {
  type    = number
  default = 4
}
variable "asg_desired" {
  type    = number
  default = 2
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

# Key pair
variable "ssh_key_name" {
  type    = string
  default = ""
}

# variable "user_data_file" {
#   type = string
# }