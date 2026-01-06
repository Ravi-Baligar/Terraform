provider "aws" {
  region = "us-east-1"
}

locals {
  instances_conf = {
    dev = {
      ami           = "ami-0aaa111bbb222ccc1"
      instance_type = "t2.micro"
    }
    test = {
      ami           = "ami-0ddd444eee555fff2"
      instance_type = "t3.micro"
    }
    staging = {
      ami           = "ami-0666ggg777hhh8883"
      instance_type = "t2.small"
    }
  }
}

resource "aws_instance" "my_instance" {
  for_each = local.instances_conf

  ami           = each.value.ami
  instance_type = each.value.instance_type

  tags = {
    Name = each.key
  }
}

output "instance_ids" {
  value = {
    for name, inst in aws_instance.my_instance: name => inst.id
  }
}