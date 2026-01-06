provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

locals {
  instances = toset(["dev", "test", "staging"])
}

resource "aws_instance" "myec2" {
  for_each = local.instances
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  tags = {
    Name = each.key
  }
}