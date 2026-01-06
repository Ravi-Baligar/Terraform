provider "aws" {
  region = "us-east-1"
}

variable "ami" {
  description = "The ami value of ec2 instance"
}

variable "instance_type" {
  description = "Instance type"

  type = map(string)
  default = {
    "dev" = "t2.micro"
    "test"= "t2.medium"
    "staging"= "t2.xlarge"
  }
}

module "ec2_module" {
  source = "./modules/ec2_creation"
  ami = var.ami
  instance_type = lookup(var.instance_type, terraform.workspace, "t2.micro")
}