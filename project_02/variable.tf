
variable "cidr" {
  description = "The Cidr block for VPC"
  default     = "10.0.0.0/16"
}

variable "availability_zone_1" {
  default = "us-east-1a"
}

variable "availability_zone_2" {
  default = "us-east-1b"
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

variable "instance_type" {
  description = "The inestance type of ec2"
  default     = "t2.micro"
}   