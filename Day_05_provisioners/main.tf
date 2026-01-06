provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "key_login" {
  key_name   = "key_login"  
  public_key = file("/home/ravi/.ssh/id_ed25519.pub") 
}

resource "aws_vpc" "myvpc" {
  cidr_block = "10.0.0.0/16"
  region = "us-east-1"
}

resource "aws_subnet" "sub1" {
  vpc_id = aws_vpc.myvpc.id
  availability_zone = "us-east-1a"
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.myvpc.id
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rts" {
  subnet_id = aws_subnet.sub1.id
  route_table_id = aws_route_table.RT.id
  
}

resource "aws_security_group" "sg" {
  name = "WEB"
  vpc_id = aws_vpc.myvpc.id
  ingress {
    description = "HTTP from VPC"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Web-sg"
  }

}

resource "aws_instance" "myec2" {
  ami = "ami-0360c520857e3138f"
  instance_type = "t2.micro"
  key_name = aws_key_pair.key_login.key_name
  subnet_id = aws_subnet.sub1.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("/home/ravi/.ssh/id_ed25519") 
    host        = self.public_ip
  }

  provisioner "file" {
    source = "/home/ravi/Documents/Terraform/Day_05_provisioners/app.py" 
    destination = "/home/ubuntu/app.py"
  }

  provisioner "remote-exec" {
    inline = [ 
      "echo 'Hello from the remote instance'",
      "sudo apt install -y python3-venv",
      "cd /home/ubuntu && python3 -m venv venv",
      "source venv/bin/activate && pip install flask",
      "nohup /home/ubuntu/venv/bin/python app.py > app.log 2>&1 &"
     ]
  }

  tags = {
    Name = "myec2"
  }

}

