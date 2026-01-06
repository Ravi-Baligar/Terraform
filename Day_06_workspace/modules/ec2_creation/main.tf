provider "aws" {
  region = "us-east-1"
}

variable "ami" {
  description = "The ami value of ec2 instance"
}

variable "instance_type" {
  description = "Instance type"
}

resource "aws_instance" "myec2" {
  ami = var.ami
  instance_type = var.instance_type
}