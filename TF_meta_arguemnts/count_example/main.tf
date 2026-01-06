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

resource "aws_instance" "myec2" {
  count = 2
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  tags = {
    Name = "test-instance-${count.index}"
  }
}

output "instance_name" {
  value = [for instance in aws_instance.myec2 : instance.id]
}

output "instance_ids" {
  value = {
    for name, inst in aws_instance.myec2: name => inst.id
  }
}