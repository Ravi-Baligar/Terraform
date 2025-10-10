provider "aws" {
  region = "us-east-1"
}

module "ec2_instance" {
  source        = "./ec2_module"
  ami_image     = "ami-0360c520857e3138f"
  instance_type = "t2.micro"
}