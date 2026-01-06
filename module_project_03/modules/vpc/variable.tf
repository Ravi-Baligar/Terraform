
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