terraform {
  backend "s3" {
    bucket = "ravi-baligar-demo"
    key = "ravi/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "terraform-lock"
  }
}