provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "myec2" {
  ami = "ami-0360c520857e3138f"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  tags = {
    Name ="ec2-demo"
  }

}
resource "aws_instance" "myec2-2" {
  ami = "ami-0360c520857e3138f"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  tags = {
    Name ="ec2-demo"
  }

}

resource "aws_s3_bucket" "name" {
  bucket = "ravi-baligar-demo"
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.name.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "terraform-lock" {
  name             = "terraform-lock"
  hash_key         = "LockID"
  billing_mode     = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}