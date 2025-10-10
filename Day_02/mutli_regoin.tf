provider "aws" {
  alias = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
    alias = "us-west-2"
    region = "us-west-2"
}

resource "aws_instance" "myec2_1" {
    ami = "ami-0360c520857e3138f"
    instance_type = "t2.micro"
    provider = aws.us-east-1
    tags = {
      name = "myec2_1"
    }
  
}

resource "aws_instance" "myec2_2" {
    ami = "ami-0360c520857e3138f"
    instance_type = "t2.micro"
    provider = aws.us-west-2
    tags = {
      name = "myec2_2"
    }
  
}