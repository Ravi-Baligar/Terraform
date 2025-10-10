provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "name" {
    ami = "ami-0360c520857e3138f"
    instance_type = "t2.micro"
    tags = {
      name = "myec2_instance"
    }
}

output "instance_id" {
  value = aws_instance.name.id
}