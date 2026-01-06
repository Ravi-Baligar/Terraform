provider "aws" {
  region = "us-east-1"
}

provider "vault" {
  address = "http://13.221.95.34:8200/"
  skip_child_token = true

  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id = "850a906c-111e-0038-362b-134037430478"
      secret_id = "2eef7c28-8ad8-658a-02da-59618c5b89d6"
    }
  }
}

data "vault_kv_secret_v2" "example" {
  mount = "kv"
  name  = "test-secret"
}

resource "aws_instance" "name" {
  ami = "ami-0360c520857e3138f"
  instance_type = "t2.micro"
  tags = {
    Name = "test"
    Secret = data.vault_kv_secret_v2.example.data["username"]
  } 
}