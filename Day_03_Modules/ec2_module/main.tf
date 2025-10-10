provider "aws" {
  region = "us-east-1"
}


resource "aws_instance" "myec2" {
  ami = var.ami_image
  instance_type = var.instance_type
  associate_public_ip_address = true
}