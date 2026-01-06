variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "instance_type" { type = string }
variable "user_data_file" {
  type = string
}
variable "ami_id" { type = string }


variable "asg_min" { type = number }
variable "asg_max" { type = number }
variable "asg_desired" { type = number }

variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids" { type = list(string) }
